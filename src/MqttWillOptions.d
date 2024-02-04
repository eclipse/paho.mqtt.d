/////////////////////////////////////////////////////////////////////////////
/// @file MqttWillOptions.d
/// Definition of MqttWillOptions class
/// @date August 28, 2016
/// @author Frank Pagliughi
/////////////////////////////////////////////////////////////////////////////

/*******************************************************************************
 * Copyright (c) 2016 Frank Pagliughi <fpagliughi@mindspring.com>
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
import std.stdio;
import std.string;
import std.conv;
import core.time;

/////////////////////////////////////////////////////////////////////////////

/**
 * Options for the Last Will and Testament message.
 */
class MqttWillOptions
{
	/** The underlying C struct for will options  */
	private MQTTAsync_willOptions opts;
	/** The topic for the LWT message */
	private string topic;
	/** The payload for the LWT message  */
	private string payload;
	/**
	 * Constructs LWT options.
	 * @param topic The topic for the LWT message.
	 * @param payload The payload for the LWT message.
	 */
	this(string topic, string payload) {
		setTopic(topic);
		setPayload(payload);
	}
	/**
	 * Constructs LWT options.
	 * @param topic The topic for the LWT message.
	 * @param payload The payload for the LWT message.
	 * @param qos The quality of service for the LWT message.
	 * @param retained The retained flag for the LWT message.
	 */
	this(string topic, string payload, int qos, bool retained) {
		this(topic, payload);
		opts.qos = qos;
		opts.retained = (retained) ? 1 : 0;
	}
	/**
	 * Gets the underlying C struct for the will options.
	 * @return The underlying C struct for the will options.
	 */
	MQTTAsync_willOptions getOptions() { return opts; }
	/**
	 * Gets a pointer to the underlying C struct for the will options. This
	 * is needed by the @ref MqttConnectOptions structure when making a
	 * connection to the broker.
	 * @return A pointer to the underlying C struct for the will options.
	 */
	MQTTAsync_willOptions* getOptionsPtr() { return &opts; }
	/**
	 * Gets the topic for the LWT message.
	 * @return The topic for the LWT message.
	 */
	string getTopic() { return topic; }
	/**
	 * Gets the payload for the LWT message.
	 * @return The payload for the LWT message.
	 */
	string getPayload() { return payload; }
	/**
	 * Gets the quality of service level for the LWT messsage.
	 * @return The quality of service for the LWT messsage.
	 */
	int getQos() { return opts.qos; }
	/**
	 * Gets the retained flag for the LWT message.
	 * @return The retained flag for the LWT message.
	 */
	bool getRetained() { return opts.qos != 0; }
	/**
	 * Sets the topic for the LWT message.
	 * @param topic The topic for the LWT message.
	 */
	void setTopic(string topic) {
		this.topic = topic;
		opts.topicName = std.string.toStringz(this.topic);
	}
	/**
	 * Sets the payload for the LWT message.
	 * @param payload The payload for the LWT message.
	 */
	void setPayload(string payload) {
		this.payload = payload;
		opts.message = std.string.toStringz(this.payload);
	}
	/**
	 * Sets the quality of service level for the LWT message.
	 * @param qos The quality of service for the LWT message.
	 */
	void setQos(int qos) {
		// TODO check qos
		opts.qos = qos;
	}
	/**
	 * Sets the retained flag for the LWT message.
	 * @param retained The retained flag for the LWT message.
	 */
	void setRetained(bool retained) {
		opts.retained = (retained) ? 1 : 0;
	}
}

