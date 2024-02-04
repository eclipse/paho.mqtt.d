/////////////////////////////////////////////////////////////////////////////
/// @file MqttConnectOptions.d
/// Definition of MqttConnectOptions class
/// @date April 24, 2015
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
import MqttWillOptions;
import MqttSSLOptions;
import std.stdio;
import std.string;
import std.conv;
import core.time;

/////////////////////////////////////////////////////////////////////////////

/**
 * Holds the set of options that control how the client connects to a
 * server.
 */
class MqttConnectOptions
{
	/** The option structure passed to the C library */
	private MQTTAsync_connectOptions opts;
	/** The user name, if any */
	private string userName;
	/** The user password, if any */
	private string passwd;
	/** The LWT message, if any */
	private MqttWillOptions willOpts;
	/** The SSL/TSL options, if any */
	private MqttSSLOptions sslOptions;

	/**
	 * Create connection options with the specified keep alive interval.
	 * @param keepAliveInterval The keep alive interval for the connection.
	 */
	this(Duration keepAliveInterval) {
		opts.keepAliveInterval = cast(int) keepAliveInterval.total!"seconds";
	}
	/**
	 * Creates the connection options.
	 * @param userName The user name for connecting to the broker.
	 * @param passwd The password for connecting to the broker.
	 */
	this(string userName, string passwd) {
		setUserName(userName);
		setPassword(passwd);
	}
	/**
	 * Gets the underlying C struct for connect options.
	 * @return The underlying C struct for connect options.
	 */
	MQTTAsync_connectOptions getOptions() { return opts; }
	/**
	 * Gets a pointer to the underlying C struct for connect options.
	 * @return A pointer to the underlying C struct for connect options.
	 */
	MQTTAsync_connectOptions* getOptionsPtr() { return &opts; }
	/**
	 * Sets the user name for connecting to the MQTT broker.
	 * @param userName The user name.
	 */
	void setUserName(string userName) {
		this.userName = userName;
		opts.username = std.string.toStringz(this.userName);
	}
	/**
	 * Sets the password for connecting to the broker.
	 * @param passwd The password.
	 */
	void setPassword(string passwd) {
		this.passwd = passwd;
		opts.password  = std.string.toStringz(this.passwd);
	}
	/**
	 * Sets the LWT message.
	 * This message will be sent out by the broker if the connection to this
	 * client is unexpected lost before disconnecting.
	 * @param willOpts The options for the LWT message.
	 */
	void setWillOptions(MqttWillOptions willOpts) {
		this.willOpts = willOpts;
		this.opts.will = this.willOpts.getOptionsPtr();
	}
	/**
	 * Sets the SSL/TSL options for the connection.
	 * @param sslOptions The SSL/TSL options.
	 */
	void setSSLOptions(MqttSSLOptions sslOptions) {
		this.sslOptions = sslOptions;
		this.opts.ssl = this.sslOptions.getOptionsPtr();
	}
}

