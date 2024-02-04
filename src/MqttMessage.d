/////////////////////////////////////////////////////////////////////////////
/// @file Message.d
/// Definition of MqttMessage class
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
import std.conv;

/////////////////////////////////////////////////////////////////////////////

/**
 * An MQTT message object.
 * The message is composed of three items:
 * @li payload - a binary array (blob) of data
 * @li QOS - The desired quality of service for message delivery.
 * @li retained - A flag indicating if the broker should keep the message.
 * See the MQTT specification for a further description of these.
 */
class MqttMessage
{
	/** The default quality of service if none is specified. */
	const int DFLT_QOS = 1;

	/** The underlying   */
	private MQTTAsync_message msg;
	/** The binary payload of the message */
	private blob payload;

//	this(immutable(MQTTAsync_message) msg) immutable {
//		//this.msg = cast(immutable MQTTAsync_message)(msg);
//		payload = cast(blob) msg.payload[0..msg.payloadlen];
//		assert(payload.length == msg.payloadlen);
//
//		this.msg = msg.dup;	//MQTTAsync_message(msg, payload);
//		this.msg.payload = cast(immutable(void)*) payload.ptr;
//		this.msg.payloadlen = cast(int) payload.length;
//	}

	/**
	 * Creates an immutable message with the given payload.
	 */
	this(blob payload) immutable {
		this.msg = immutable MQTTAsync_message(payload);
		this.payload = payload;
	}
	/**
	 * Creates a message from a C library message structure.
	 * This does a deep copy of the message payload.
	 * @param msg An MQTT C library message structure.
	 */
	this(MQTTAsync_message msg) {
		this.msg = msg;
		payload = cast(blob) msg.payload[0..msg.payloadlen].dup();
		assert(payload.length == msg.payloadlen);
		this.msg.payload = cast(immutable(void)*) payload.ptr;
		this.msg.payloadlen = cast(int) payload.length;
	}
	/**
	 * Creates a message object.
	 * @param payload The payload of the messages.
	 * @param qos The quality of service for the message.
	 * @param retained Whether the message should be retained by the broker.
	 */
	this(blob payload, int qos, bool retained) {
		setPayload(payload);
		msg.qos = qos;
		msg.retained = retained;
	}
	/**
	 * Creates a message object.
	 * @param payload The payload of the messages.
	 * @param qos The quality of service for the message.
	 */
	this(blob payload, int qos) {
		setPayload(payload);
		msg.qos = qos;
	}
	/**
	 * Creates a message object.
	 * @param payload The payload of the messages.
	 */
	this(blob payload) {
		setPayload(payload);
	}
	/**
	 * Creates a message object.
	 * @param payload A string to use as the payload of the messages.
	 * @param qos The quality of service for the message.
	 * @param retained Whether the message should be retained by the broker.
	 */
	this(string payload, int qos, bool retained) {
		this(cast(blob) payload, qos, retained);
	}
	/**
	 * Creates a message object.
	 * @param payload A string to use as the payload of the messages.
	 * @param qos The quality of service for the message.
	 */
	this(string payload, int qos) {
		this(cast(blob) payload, qos);
	}
	/**
	 * Creates a message object.
	 * @param payload A string to use as the payload of the messages.
	 */
	this(string payload) {
		this(cast(blob) payload);
	}
	/**
	 * Create a duplicate (deep) copy of the message.
	 */
	inout(MqttMessage) dup() inout {
		auto m = new MqttMessage(this.msg);
		return cast(inout(MqttMessage)) m;
	}
	/**
	 * Gets the underlying C message structure.
	 * @return The underlying C message structure.
	 */
	MQTTAsync_message getMessage() { return msg; }
	/**
	 * Clears the payload, resetting it to be empty.
	 */
	void clear_payload() {
		msg.payloadlen = 0;
		msg.payload = null;
		payload = null;
	}
	/**
	 * Gets the payload
	 */
	blob getPayload() const { return payload; }
	/**
	 * Gets a string representation of the message payload.
	 * @return A string representation of the message payload.
	 */
	string getPayloadStr() const { return cast(string) payload[0..$]; }
	/**
	 * Returns the quality of service for this message.
	 * @return The quality of service for this message.
	 */
	int getQos() { return msg.qos; }
	/**
	 * Returns whether or not this message might be a duplicate of one which
	 * has already been received.
	 * @return true this message might be a duplicate of one which
	 * has already been received, false otherwise
	 */
	bool isDuplicate() { return msg.dup != 0; }
	/**
	 * Returns whether or not this message should be/was retained by the
	 * server.
	 * @return true if this message should be/was retained by the
	 * server, false otherwise.
	 */
	bool isRetained() { return msg.retained != 0; }
	/**
	 * Sets the payload of this message to be the specified string.
	 * @param payload A string to use as the message payload.
	 */
	void setPayload(blob payload) {
		this.payload = payload;
		msg.payload = cast(immutable(void)*) payload.ptr;
		// TODO: Check length for valid MQTT len?
		msg.payloadlen = cast(int) payload.length;
	}
	/**
	 * Sets the payload of this message to be the specified string.
	 * @param payload A string to use as the message payload.
	 */
	void setPayload(string payload) {
		setPayload(to!blob(payload));
	}
	/**
	 * Sets the quality of service for this message.
	 * @param qos The quality of service for this message.
	 */
	void setQos(int qos) {
		// TODO: validate the qos 0<= qos <=2
		msg.qos = qos;
	}
	/**
	 * Whether or not the publish message should be retained by the
	 * messaging engine.
	 * @param retained
	 */
	void setRetained(bool retained) { msg.retained = (retained) ? 1 : 0; }
	/**
	 * Gets a string representation of the message payload.
	 * @return A string representation of the message payload.
	 */
	override string toString() const {
		return cast(string) payload[0..$];
	}
}

