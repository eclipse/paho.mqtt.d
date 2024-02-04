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
 * Options for a connection using SSL/TSL.
 */
class MqttSSLOptions
{
	/** The underlying C struct for SSL options  */
	private MQTTAsync_SSLOptions opts;
	/** The file containing trusted public certificates */
	private string trustStore;
	/** The file containing the public certificate chain for the client */
	private string keyStore;
	/** The file containing the client's private key */
	private string privateKey;
	/** The password to load the client's privateKey (if encrypted) */
	private string privateKeyPassword;
	/** The list of cipher suites for the SSL handshake */
	private string enabledCipherSuites;

	/**
	 * Constructs the SSL/TSL options.
	 * @param trustStore The file containing trusted public certificates
	 * @param keyStore The file containing the public certificate chain for
	 *  			   the client
	 * @param privateKey The file containing the client's private key.
	 */
	this(string trustStore, string keyStore, string privateKey) {
		setTrustStore(trustStore);
		setKeyStore(keyStore);
		setPrivateKey(privateKey);
	}
	/**
	 * Constructs the SSL/TSL options.
	 * @param trustStore The file containing trusted public certificates
	 * @param keyStore The file containing the public certificate chain for
	 *  			   the client
	 * @param privateKey The file containing the client's private key.
	 * @param privateKeyPassword The password to load the client's
	 *  						 privateKey (if encrypted)
	 */
	this(string trustStore, string keyStore, string privateKey,
			string privateKeyPassword) {
		setTrustStore(trustStore);
		setKeyStore(keyStore);
		setPrivateKey(privateKey);
		setPrivateKeyPassword(privateKeyPassword);
	}
	/**
	 * Constructs the SSL/TSL options.
	 * @param trustStore The file containing trusted public certificates
	 * @param keyStore The file containing the public certificate chain for
	 *  			   the client
	 * @param privateKey The file containing the client's private key.
	 * @param privateKeyPassword The password to load the client's
	 *  						 privateKey (if encrypted)
	 * @param enabledCipherSuites The list of cipher suites for the SSL
	 *  						  handshake
	 * @param enableServerCertAuth The option to verify the server
	 *  						   certificate.
	 */
	this(string trustStore, string keyStore, string privateKey,
			string privateKeyPassword, string enabledCipherSuites,
			bool enableServerCertAuth) {
		this(trustStore,keyStore,privateKey,privateKeyPassword);
		setEnabledCipherSuites(enabledCipherSuites);
		setEnableServerCertAuth(enableServerCertAuth);
	}
	/**
	 * Gets the underlying C struct for the will options.
	 * @return The underlying C struct for the will options.
	 */
	MQTTAsync_SSLOptions getOptions() { return opts; }
	/**
	 * Gets a pointer to the underlying C struct for the will options. This
	 * is needed by the @ref MqttConnectOptions structure when making a
	 * connection to the broker.
	 * @return A pointer to the underlying C struct for the will options.
	 */
	MQTTAsync_SSLOptions* getOptionsPtr() { return &opts; }
	/**
	 * Gets the name of the file containing the public digital certificates
	 * trusted by the client.
	 * @return The file containing trusted public certificates
	 */
	string getTrustStore() { return trustStore; }
	/**
	 * Returns the file containing the public certificate chain of the client.
	 * @return string
	 */
	string getKeyStore() { return keyStore; }
	/**
	 * Returns the file containing the client's private key.
	 * @return string
	 */
	string getPrivateKey() { return privateKey; }
	/**
	 * Gets the password to load the client's privateKey if encrypted.
	 * @return The password to load the client's privateKey if encrypted.
	 */
	string getPrivateKeyPassword() { return privateKeyPassword; }
	/**
	 * Returns the list of cipher suites that the client will present to the
	 * server during the SSL handshake.
	 * @return The list of cipher suites that the client will present to the
	 *  	   server during the SSL handshake.
	 */
	string getEnabledCipherSuites() { return enabledCipherSuites; }
	/**
	 * Gets whether we verify the server certificate.
	 * @return Whether we verify the server certificate.
	 */
	bool getEnableServerCertAuth() const {
		return opts.enableServerCertAuth != 0;
	}
	/**
	 * Sets the name of the file containing the public digital certificates
	 * trusted by the client.
	 * @param trustStore The file containing the public digital certificates
	 *  				 trusted by the client.
	 */
	void setTrustStore(string trustStore) {
		this.trustStore = trustStore;
		opts.trustStore = std.string.toStringz(this.trustStore);
	}
	/**
	 * Sets the name of the file containing the public certificate chain of
	 * the client.
	 * @param keyStore The file containing the public certificate chain of
	 *  			   the client.
	 */
	void setKeyStore(string keyStore) {
		this.keyStore = keyStore;
		opts.keyStore = std.string.toStringz(this.keyStore);
	}
	/**
	 * Sets the file containing the client's private key.
	 * @param privateKey The file containing the client's private key. =
	 */
	void setPrivateKey(string privateKey) {
		this.privateKey = privateKey;
		opts.privateKey = std.string.toStringz(this.privateKey);
	}
	/**
	 * Sets the password to load the client's privateKey (if encrypted).
	 * @param privateKeyPassword The password to load the client's
	 *  						 privateKey.
	 */
	void setPrivateKeyPassword(string privateKeyPassword) {
		this.privateKeyPassword = privateKeyPassword;
		opts.privateKeyPassword = std.string.toStringz(this.privateKeyPassword);
	}
	/**
	 * Sets the list of cipher suites that the client will present to the server
	 * during the SSL handshake.
	 *
	 * For a  full explanation of the cipher list format, please see the
	 * OpenSSL on-line documentation:
	 * http://www.openssl.org/docs/apps/ciphers.html#CIPHER_LIST_FORMAT
	 *
	 * If this setting is ommitted, its default value will be "ALL", that
	 * is, all the cipher suites -excluding those offering no encryption-
	 * will be considered.
	 *
	 * This setting can be used to set an SSL anonymous connection ("aNULL"
	 * string value, for instance).
	 *
	 * @param enabledCipherSuites The list of cipher suites that the client
	 *  						  will present to the server during the SSL
	 *  						  handshake.
	 */
	void setEnabledCipherSuites(string enabledCipherSuites) {
		this.enabledCipherSuites = enabledCipherSuites;
		opts.enabledCipherSuites = std.string.toStringz(this.enabledCipherSuites);
	}
	/**
	 * Sets the option to verify the server certificate.
	 * @param enablServerCertAuth Whether to verify the server certificate.
	 */
	void setEnableServerCertAuth(bool enablServerCertAuth) {
		opts.enableServerCertAuth = (enablServerCertAuth) ? 1 : 0;
	}
}

