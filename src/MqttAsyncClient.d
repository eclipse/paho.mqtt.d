/////////////////////////////////////////////////////////////////////////////
/// @file MqttAsyncClient.d
/// The MQTT async_client class
/// @date Feb 21, 2015
/// @author Frank Pagliughi
/////////////////////////////////////////////////////////////////////////////

/*******************************************************************************
 * Copyright (c) 2015-2016 Frank Pagliughi <fpagliughi@mindspring.com>
 *
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v2.0
 * and Eclipse Distribution License v1.0 which accompany this distribution.
 *
 * The Eclipse Public License is available at
 *    http://www.eclipse.org/legal/epl-v20.html
 * and the Eclipse Distribution License is available at
 *   http://www.eclipse.org/org/documents/edl-v10.php.
 *
 * Contributors:
 *    Frank Pagliughi - initial implementation and documentation
 *******************************************************************************/

import MQTTAsync;
import MqttMessage;
import MqttToken;
import MqttException;
import MqttCallback;
import MqttConnectOptions;
import MqttActionListener;

import std.stdio;
import std.string;
import std.conv;
import std.concurrency;
import std.typecons;
import core.memory;

/////////////////////////////////////////////////////////////////////////////
// Callbacks from the C library.
//
// Note that the Garbage Collector lockdown technique for C callbacks is
// described in the Phobos documentation, here:
// http://dlang.org/phobos/core_memory.html#.GC.addRoot
//

extern (C)
{
	/**
	 * Callback for when the connection to the broker is lost.
	 * @param context Pointer to the locked down client object.
	 * @param cause
	 */
	void onConnectionLostCallback(void *context, char *cause)
	{
		if (context == null) return;

		GC.removeRoot(context);
		GC.clrAttr(context, GC.BlkAttr.NO_MOVE);
		auto cli = cast(MqttAsyncClient) context;

		//tok.onComplete(MQTTASYNC_SUCCESS);
	}
	/**
	 * Callback from an unsuccessful connection.
	 * @param context Pointer to the locked down token object.
	 * @param response
	 */
	int onMessageArrivedCallback(void *context, char *topicName, int topicLen, MQTTAsync_message *msg)
	{
		if (context == null) return 0;

		//GC.removeRoot(context);
		//GC.clrAttr(context, GC.BlkAttr.NO_MOVE);
		auto cli = cast(MqttAsyncClient) context;

		string topic = to!string(topicName);
		auto m = new MqttMessage(*msg);

		cli.onMessageArrived(topic, cast(immutable) m);
		//cli.onMessageArrived(topic, m);

		MQTTAsync_freeMessage(&msg);
		MQTTAsync_free(topicName);

		// TODO: Should the user code determine the return value?
		// The Java version does doesn't seem to...
		return (1);
	}

	void onDeliveryCompleteCallback(void *context, MQTTAsync_token token)
	{
		if (context == null) return;

		GC.removeRoot(context);
		GC.clrAttr(context, GC.BlkAttr.NO_MOVE);
		auto cli = cast(MqttAsyncClient) context;

		//tok.onComplete(retCode);
	}
}

/////////////////////////////////////////////////////////////////////////////

/**
 * An asynchronous MQTT connection client.
 *
 */
class MqttAsyncClient
{
	/** The address/URI of the broker */
	private string serverURI;
	/** The client ID for the connection */
	private string clientId;
	/** The underlying C connection client */
	private MQTTAsync cli = null;
	/** A user-supplied callback object */
	private MqttCallback callback = null;

	private Tid msgTid;

	/**
	 * Helper to check a return value from the C library.
	 * This will create and throw an exception if the return code indicated
	 * an error.
	 * @param ret The return code from the C library. A value of 0 is
	 *  		  success, <0 is an error.
	 */
	private void chkRet(int ret) {
		if (ret != 0)
			throw new MqttException(ret);
	}
	/**
	 * Creates an asynchronous MQTT client object.
	 * @param serverURI The URI of the MQTT broker.
	 * @param clientId The unique identifier for this client.
	 */
	this(string serverURI, string clientId) {
		this.serverURI = serverURI;
		this.clientId = clientId;
		chkRet(MQTTAsync_create(&cli, std.string.toStringz(serverURI),
					 std.string.toStringz(clientId), MQTTCLIENT_PERSISTENCE_NONE, null));
	}
	/**
	 * Callback handler for incoming messages on this client.
	 * @param topic The topic on which the message arrived.
	 * @param msg The message.
	 */
	private void onMessageArrived(string topic, immutable MqttMessage msg) {
		if (this.callback !is null)
			this.callback.messageArrived(topic, msg);

		if (msgTid != Tid.init)
			msgTid.send(topic, rebindable(msg));
	}
	/**
	 * Gets the underlying C client object
	 * @return The underlying C client object
	 */
	MQTTAsync handle() { return cli; }
	/**
	 * Determines if this object has been created sucessfully.
	 * @return @em true if this object has been created sucessfully, @em
	 *  	   false if there was an error upon creation.
	 */
	bool isOK() { return cli != null; }
	/**
	 * Sets an asynchronous callback object.
	 *
	 * @param cb
	 */
	void setCallback(MqttCallback cb) {
		this.callback = cb;
		void* context = cast(void*) this;
		MQTTAsync_setCallbacks(cli, context, &onConnectionLostCallback,
							   &onMessageArrivedCallback, &onDeliveryCompleteCallback);
	}

	void setMessageThread(Tid msgTid) {
		this.msgTid = msgTid;
		void* context = cast(void*) this;
		MQTTAsync_setCallbacks(cli, context, &onConnectionLostCallback,
							   &onMessageArrivedCallback, &onDeliveryCompleteCallback);
	}
	/**
	 * Determines if this client is currently connected to a message
	 * broker/server.
	 * @return @em true if if this client is currently connected to a
	 *  	   server, @em false if not.
	 */
	bool isConnected() { return MQTTAsync_isConnected(cli) != 0; }

	/**
	 * Connects to an MQTT server using the default options.
	 * @return token used to track and wait for the connect to complete. The
	 *  	   token will be passed to any callback that has been set.
	 * @throw MqttException for non security related problems
	 * @throw security_exception for security related problems
	 */
	MqttToken connect() {
		/*
		auto opt = new MQTTAsync_connectOptions;
		auto tok = new MqttToken(this);

		opt.context = cast(void*) tok;
		opt.onSuccess = &MqttToken.onSuccess;
		opt.onFailure = &MqttToken.onFailure;

		// Lock down the MqttToken until the callback occurs.
		tok.lockMem();

		int ret = MQTTAsync_connect(cli, opt);
		if (ret != 0) {
			tok.unlockMem();
			throw new MqttException(ret);
		}
		return tok;
		*/
		return connect(null, null, null);
	}

	MqttToken connect(MqttConnectOptions opts, Object userContext,
					  IMqttActionListener listener) {
		auto opt = (opts is null) ? MQTTAsync_connectOptions() : opts.getOptions();
		auto tok = new MqttToken(this, userContext, listener);

		opt.context = cast(void*) tok;
		opt.onSuccess = &MqttToken.onSuccess;
		opt.onFailure = &MqttToken.onFailure;

		// Lock down the MqttToken until the callback occurs.
		tok.lockMem();

		int ret = MQTTAsync_connect(cli, &opt);
		if (ret != 0) {
			tok.unlockMem();
			throw new MqttException(ret);
		}
		return tok;
	}

	MqttToken disconnect() {
		auto opt = new MQTTAsync_disconnectOptions;
		auto tok = new MqttToken(this);

		opt.context = cast(void*) tok;
		opt.onSuccess = &MqttToken.onSuccess;
		opt.onFailure = &MqttToken.onFailure;

		// Lock down the MqttToken until the callback occurs.
		tok.lockMem();

		int ret = MQTTAsync_disconnect(cli, opt);
		if (ret != 0) {
			tok.unlockMem();
			throw new MqttException(ret);
		}
		return tok;
	}

	MqttDeliveryToken publish(string topic, string payload, int qos, bool retained) {
		auto opt = new MQTTAsync_responseOptions;
		MqttDeliveryToken tok = null;

		int ret = MQTTAsync_send(cli, std.string.toStringz(topic),
					cast(int) payload.length, payload.ptr, qos, retained?1:0, opt);

		if (ret != 0)
			throw new MqttException(ret);

		// TODO: Create a message object for this token
		tok = new MqttDeliveryToken(this, null, opt.token);
		return tok;
	}

	MqttDeliveryToken publish(string topic, MqttMessage msg) {
		MQTTAsync_message m = msg.getMessage();
		auto opt = new MQTTAsync_responseOptions;
		MqttDeliveryToken tok = null;

		int ret = MQTTAsync_sendMessage(cli, std.string.toStringz(topic), &m, opt);

		if (ret != 0)
			throw new MqttException(ret);

		tok = new MqttDeliveryToken(this, msg, opt.token);
		return tok;
	}

	MqttToken subscribe(string topic, int qos) {
		return subscribe(topic, qos, null, null);
	}

	MqttToken subscribe(string topic, int qos, Object userContext,
						IMqttActionListener listener) {
		auto opt = new MQTTAsync_responseOptions;
		auto tok = new MqttToken(this, null, listener);

		opt.context = cast(void*) tok;
		opt.onSuccess = &MqttToken.onSuccess;
		opt.onFailure = &MqttToken.onFailure;

		// Lock down the MqttToken until the callback occurs.
		tok.lockMem();

		int ret = MQTTAsync_subscribe(cli, std.string.toStringz(topic), qos, opt);

		if (ret != 0) {
			tok.unlockMem();
			throw new MqttException(ret);
		}
		return tok;
	}

	MqttToken unsubscribe(string topic) {
		return unsubscribe(topic, null, null);
	}

	MqttToken unsubscribe(string topic, Object userContext,
						  IMqttActionListener listener) {
		auto opt = new MQTTAsync_responseOptions;
		auto tok = new MqttToken(this, userContext, listener);

		opt.context = cast(void*) tok;
		opt.onSuccess = &MqttToken.onSuccess;
		opt.onFailure = &MqttToken.onFailure;

		// Lock down the MqttToken until the callback occurs.
		tok.lockMem();

		int ret = MQTTAsync_unsubscribe(cli, std.string.toStringz(topic), opt);

		if (ret != 0) {
			tok.unlockMem();
			throw new MqttException(ret);
		}
		return tok;
	}

}

