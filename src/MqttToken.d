/////////////////////////////////////////////////////////////////////////////
/// @file MqttToken.d
/// Definition of the IMqttToken interface and the MqttToken and 
/// MqttDeliveryToken classes
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
import MqttAsyncClient;
import MqttException;
import MqttActionListener;
import MqttMessage;

import std.stdio;
import core.sync.condition;
import core.memory;

/////////////////////////////////////////////////////////////////////////////
//								IMqttToken
/////////////////////////////////////////////////////////////////////////////

/**
 * Interface for an MQTT token.
 * This is similar to a future which can be used to track the progress of an
 * asynchronous operation, and become signaled when the operation is
 * complete.
 */
interface IMqttToken
{
	/**
	 * Determines if the asynchronous action has completed.
	 * @return @em true if the action completed, @em false if it is still in
	 *  	   progress.
	 */
	bool isComplete();
	/**
	 * Blocks the caller until the asynchronous action is completed.
	 * @throw MqttException on a delivery error.
	 */
	void waitForCompletion();
	/**
	 * Blocks the caller until the asynchronous action is completed or a
	 * timeout occurs.
	 * @param timeout The amount of time to wait for the action to complete.
	 * @return @em true if the action completed sucessfully, @em false on a
	 *  	   timeout.
	 * @throw MqttException on a delivery error.
	 */
	bool waitForCompletion(Duration timeout);
}

/////////////////////////////////////////////////////////////////////////////
// Callbacks from the C library.
//
// The 'context' for the callback is the address of a token which should
// be signaled that the operation completed. The associated code sent to
// the token indicates whether the operation succeeded or failed.
//
// Note that when the operation is underway (inflight) the associated
// token object is locked down in the Garbage Collector.
//
// The Garbage Collector lockdown technique for C callbacks is
// described in the Phobos documentation, here:
// http://dlang.org/phobos/core_memory.html#.GC.addRoot
//

extern (C)
{
	/**
	 * Callback from a successful operation.
	 * @param context Pointer to the locked down token object.
	 * @param response
	 */
	void onSuccess(void *context, MQTTAsync_successData* response)
	{
		if (context == null) return;
		auto tok = cast(MqttToken) context;
		tok.onComplete(MQTTASYNC_SUCCESS);
	}
	/**
	 * Callback from an unsuccessful operation.
	 * @param context Pointer to the locked down token object.
	 * @param response
	 */
	void onFailure(void *context, MQTTAsync_failureData* response)
	{
		if (context == null) return;

		int retCode = MQTTASYNC_FAILURE;
		if (response != null)
			retCode = (*response).code;

		auto tok = cast(MqttToken) context;
		tok.onComplete(retCode);
	}
}

/////////////////////////////////////////////////////////////////////////////
//								MqttToken
/////////////////////////////////////////////////////////////////////////////

/**
 * Provides a mechanism to track the progress of an asynchronous action.
 */
class MqttToken : IMqttToken
{
	/** The mutex used to signal the object */
	private Mutex mut;
	/** The condition variable used to signal the object */
	private Condition cond;
	/** The MQTT client that created the token */
	private MqttAsyncClient cli;
	/** The MQTT integer token for the message (the message identifier) */
	private int msgId;
	/** Whether the action has completed */
	private bool completed;
	/** The success/failure return code for the action */
	private int retCode;
	/** An arbitrary object supplied by the caller */
	private Object userContext;
	/** A listener to receive a callback when the action completes */
	private IMqttActionListener listener = null;

	/**
	 * Creates a token with an action listener attached.
	 * @param cli The client object that is handling the action.
	 * @param listener The listener to receive a callback when the action
	 *  			   completes. This can be null is a callback is not
	 *  			   desired.
	 */
	this(MqttAsyncClient cli, Object userContext, IMqttActionListener listener) {
		mut = new Mutex;
		cond = new Condition(mut);
		this.cli = cli;
		msgId = 0;
		completed = false;
		this.userContext = userContext;
		this.listener = listener;
	}
	/**
	 * Creates a token without an action listener attached.
	 */
	this(MqttAsyncClient cli) { this(cli, null, null); }
	/**
	 * Callback for when the associated action completes.
	 * This is normally called in the context of the C library callback
	 * thread when the asynchronous action has finished - either from
	 * success or failure, as determined by the retCode parameter.
	 * @param retCode The response return code for the operation indicating
	 *  			  success or a particular failure.
	 */
	private void onComplete(int retCode) {
		unlockMem();
		synchronized (mut) {
			this.retCode = retCode;
			completed = true;
			cond.notify();
		}
		if (listener !is null) {
			//writeln("Calling listener");
			if (retCode == 0)
				listener.onSuccess(this);
			else
				listener.onFailure(this, new MqttException(retCode));
		}
	}

	/**
	 * Lock the object so that the GC doesn't move it.
	 * The address of an object is often passed down to the C library as a
	 * callback "context" pointer. We need to make sure that the object does
	 * not move during the operation, and is at the same address when the
	 * callback fires.
	 * This is normally handled internally by the library.
	 */
	void lockMem() {
		auto p = cast(void*) this;
		GC.addRoot(p);
		GC.setAttr(p, GC.BlkAttr.NO_MOVE);
	}
	/**
	 * Unlocks the object
	 */
	void unlockMem() {
		auto p = cast(void*) this;
		GC.removeRoot(p);
		GC.clrAttr(p, GC.BlkAttr.NO_MOVE);
	}
	/**
	 * Determines whether the asynchronous action has finished.
	 * @return @em true if the asynchronous action has finished, @em false
	 *  	   if not.
	 */
	override bool isComplete() {
		synchronized (mut) {
			return completed;
		}
	}
	/**
	 * Blocks the caller until the asynchronous action has finished.
	 * @throws MqttException if an error occurred in the action.
	 */
	void waitForCompletion() {
		int ret;
		synchronized (mut) {
			while (!completed)
				cond.wait();
			ret = retCode;
		}
		if (ret != MQTTASYNC_SUCCESS)
			throw new MqttException(ret);
	}
	/**
	 * Blocks the caller until the asynchronous action has finished or the
	 * timeout expires.
	 * @param timeout The maximum amount of time to wait for the action to
	 *  			  finish.
	 * @return @em true if the action finished successfully, @em false if
	 *  	   the timeout occurred.
	 * @throws MqttException if an error occurred in the action.
	 */
	bool waitForCompletion(Duration timeout) {
		int ret;
		synchronized (mut) {
			while (!completed) {
				if (!cond.wait(timeout))
					return false;
			}
			ret = retCode;
		}
		if (ret != MQTTASYNC_SUCCESS)
			throw new MqttException(ret);

		return true;
	}
}

/////////////////////////////////////////////////////////////////////////////
//						MqttDeliveryToken
/////////////////////////////////////////////////////////////////////////////

/**
 * Provides a mechanism to track the delivery progress of a message.
 * This is a token which tracks the publication of a message. The
 * implementation is
 */
class MqttDeliveryToken : IMqttToken
{
	/** The client that is handling the message */
	private MqttAsyncClient cli;
	/** The integer token fot the message (the message ID) */
	private MQTTAsync_token msgId;
	/** A reference to the message itself */
	private MqttMessage msg;

	/**
	 * Creates a delivery token
	 * @param cli The client that is handling the message
	 * @param msg The message
	 * @param msgId
	 */
	this(MqttAsyncClient cli, MqttMessage msg, MQTTAsync_token msgId) {
		this.cli = cli;
		this.msg = msg;
		this.msgId = msgId;
	}
	/**
	 * Gets the message associated with this token.
	 * @return The message associated with this token.
	 */
	MqttMessage getMessage() { return msg; }
	/**
	 * Determines if the asynchronous action has completed.
	 * The action is complete when the message has been sent to the broker
	 * and all acknowledgements have occured, or if an error occurs in
	 * delivery.
	 * @return @em true if the action completed, @em false if it is still in
	 *  	   progress.
	 */
	override bool isComplete() {
		int ret = MQTTAsync_isComplete(cli.handle(), msgId);
		if (ret != MQTTASYNC_SUCCESS && ret != MQTTASYNC_TRUE)
			throw new MqttException(ret);
		return ret == MQTTASYNC_TRUE;
	}
	/**
	 * Blocks the caller until the asynchronous action is completed.
	 * @throw MqttException on a delivery error.
	 */
	override void waitForCompletion() {
		int ret = MQTTAsync_waitForCompletion(cli.handle(), msgId, cast(uint) -1);
		if (ret != MQTTASYNC_SUCCESS)
			throw new MqttException(ret);
	}
	/**
	 * Blocks the caller until the asynchronous action is completed or a
	 * timeout occurs.
	 * @param timeout The amount of time to wait for the action to complete.
	 * @return @em true if the action completed sucessfully, @em false on a
	 *  	   timeout.
	 * @throw MqttException on a delivery error.
	 */
	override bool waitForCompletion(Duration timeout) {
		uint ms = cast(uint) timeout.total!"msecs";
		int ret = MQTTAsync_waitForCompletion(cli.handle(), msgId, ms);
		if (ret != MQTTASYNC_SUCCESS && ret != MQTTASYNC_FAILURE)
			throw new MqttException(ret);
		return (ret == MQTTASYNC_SUCCESS);
	}
}

