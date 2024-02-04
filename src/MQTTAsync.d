/* Converted to D from MQTTAsync.h by htod */
module MQTTAsync;
/*******************************************************************************
 * Copyright (c) 2009, 2015 IBM Corp.
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
 *    Ian Craggs - initial API and implementation
 *    Ian Craggs, Allan Stockdill-Mander - SSL connections
 *    Ian Craggs - multiple server connection support
 *    Ian Craggs - MQTT 3.1.1 support
 *******************************************************************************/

/********************************************************************/

/**
 * @cond MQTTAsync_main
 * @mainpage Asynchronous MQTT client library for C
 *
 * &copy; Copyright IBM Corp. 2009, 2015
 *
 * @brief An Asynchronous MQTT client library for C.
 *
 * An MQTT client application connects to MQTT-capable servers.
 * A typical client is responsible for collecting information from a telemetry
 * device and publishing the information to the server. It can also subscribe
 * to topics, receive messages, and use this information to control the
 * telemetry device.
 *
 * MQTT clients implement the published MQTT v3 protocol. You can write your own
 * API to the MQTT protocol using the programming language and platform of your
 * choice. This can be time-consuming and error-prone.
 *
 * To simplify writing MQTT client applications, this library encapsulates
 * the MQTT v3 protocol for you. Using this library enables a fully functional
 * MQTT client application to be written in a few lines of code.
 * The information presented here documents the API provided
 * by the Asynchronous MQTT Client library for C.
 *
 * <b>Using the client</b><br>
 * Applications that use the client library typically use a similar structure:
 * <ul>
 * <li>Create a client object</li>
 * <li>Set the options to connect to an MQTT server</li>
 * <li>Set up callback functions</li>
 * <li>Connect the client to an MQTT server</li>
 * <li>Subscribe to any topics the client needs to receive</li>
 * <li>Repeat until finished:</li>
 *     <ul>
 *     <li>Publish any messages the client needs to</li>
 *     <li>Handle any incoming messages</li>
 *     </ul>
 * <li>Disconnect the client</li>
 * <li>Free any memory being used by the client</li>
 * </ul>
 * Some simple examples are shown here:
 * <ul>
 * <li>@ref publish</li>
 * <li>@ref subscribe</li>
 * </ul>
 * Additional information about important concepts is provided here:
 * <ul>
 * <li>@ref async</li>
 * <li>@ref wildcard</li>
 * <li>@ref qos</li>
 * <li>@ref tracing</li>
 * </ul>
 * @endcond
 */


// ----- Persistence -----

/**
 * This <i>persistence_type</i> value specifies the default file system-based
 * persistence mechanism (see MQTTClient_create()).
 */
const MQTTCLIENT_PERSISTENCE_DEFAULT = 0;
/**
 * This <i>persistence_type</i> value specifies a memory-based
 * persistence mechanism (see MQTTClient_create()).
 */
const MQTTCLIENT_PERSISTENCE_NONE = 1;
/**
 * This <i>persistence_type</i> value specifies an application-specific
 * persistence mechanism (see MQTTClient_create()).
 */
const MQTTCLIENT_PERSISTENCE_USER = 2;

// ----- End Persistence -----

/**
 * Return code: No error. Indicates successful completion of an MQTT client
 * operation.
 */
const MQTTASYNC_SUCCESS = 0;
/**
 * Return code: A generic error code indicating the failure of an MQTT client
 * operation.
 */
const MQTTASYNC_FAILURE = -1;
/**
 * error code -2 is MQTTAsync_PERSISTENCE_ERROR
 */
const MQTTASYNC_PERSISTENCE_ERROR = -2;
/**
 * Return code: The client is disconnected.
 */
const MQTTASYNC_DISCONNECTED = -3;
/**
 * Return code: The maximum number of messages allowed to be simultaneously
 * in-flight has been reached.
 */
const MQTTASYNC_MAX_MESSAGES_INFLIGHT = -4;
/**
 * Return code: An invalid UTF-8 string has been detected.
 */
const MQTTASYNC_BAD_UTF8_STRING = -5;
/**
 * Return code: A NULL parameter has been supplied when this is invalid.
 */
const MQTTASYNC_NULL_PARAMETER = -6;
/**
 * Return code: The topic has been truncated (the topic string includes
 * embedded NULL characters). String functions will not access the full topic.
 * Use the topic length value to access the full topic.
 */
const MQTTASYNC_TOPICNAME_TRUNCATED = -7;
/**
 * Return code: A structure parameter does not have the correct eyecatcher
 * and version number.
 */
const MQTTASYNC_BAD_STRUCTURE = -8;
/**
 * Return code: A qos parameter is not 0, 1 or 2
 */
const MQTTASYNC_BAD_QOS = -9;
/**
 * Return code: All 65535 MQTT msgids are being used
 */
const MQTTASYNC_NO_MORE_MSGIDS = -10;
/**
 * Return code: the request is being discarded when not complete
 */
const MQTTASYNC_OPERATION_INCOMPLETE = -11;
/**
 * Return code: no more messages can be buffered
 */
const MQTTASYNC_MAX_BUFFERED_MESSAGES = -12;


/**
 * Default MQTT version to connect with.  Use 3.1.1 then fall back to 3.1
 */
const MQTTVERSION_DEFAULT = 0;
/**
 * MQTT version to connect with: 3.1
 */
const MQTTVERSION_3_1 = 3;
/**
 * MQTT version to connect with: 3.1.1
 */
const MQTTVERSION_3_1_1 = 4;

/**
 * Bad return code from subscribe, as defined in the 3.1.1 specification
 */
const MQTT_BAD_SUBSCRIBE = 0x80;

/**
 * A handle representing an MQTT client. A valid client handle is available
 * following a successful call to MQTTAsync_create().
 */
extern (C):
alias void *MQTTAsync;

/**
 * A value representing an MQTT message. A token is returned to the
 * client application when a message is published. The token can then be used to
 * check that the message was successfully delivered to its destination (see
 * MQTTAsync_publish(), MQTTAsync_publishMessage(),
 * MQTTAsync_deliveryComplete(), and
 * MQTTAsync_getPendingTokens()).
 */
alias int MQTTAsync_token;

/**
 * The type used for message payloads, a binary 'blob'.
 * This is just an array of unsigned bytes.
 */
alias immutable(ubyte)[] blob;

/**
 * A structure representing the payload and attributes of an MQTT message.
 * The message topic is not part of this structure (see
 * MQTTAsync_publishMessage(), MQTTAsync_publish(), MQTTAsync_receive(),
 * MQTTAsync_freeMessage() and MQTTAsync_messageArrived()).
 *
 * The default construction matches a "C" MQTTAsync_message_initializer
 */
struct MQTTAsync_message
{
	immutable char[4] struct_id = "MQTM";
	int struct_version = 0;
	int payloadlen;
	const(void)* payload;
	int qos;
	int retained;
	int dup;
	int msgid;

//	this(MQTTAsync_message msg, immutable(void)* payload, int payloadlen) {
//		this = msg;
//		this.payload = payload;
//		this.payloadlen = payloadlen;
//	}

/*
	this(immutable(MQTTAsync_message) msg, blob payload) immutable {
		//this = msg.dup;
		//struct_id = msg.struct_id;
		this.payload = cast(const(void)*) payload.ptr;
		this.payloadlen = cast(int) payload.length;
		qos = msg.qos;
		retained = msg.retained;
	}
*/

	this(blob payload, int qos=0, bool retained=false, bool dup=false) immutable {
		this.payload = payload.ptr;
		this.payloadlen = cast(int) payload.length;
		this.qos = qos;
		this.retained = retained ? 1 : 0;
		this.dup = dup ? 1 : 0;
	}

	this(blob payload, int qos=0, bool retained=false, bool dup=false) {
		this.payload = payload.ptr;
		this.payloadlen = cast(int) payload.length;
		this.qos = qos;
		this.retained = retained ? 1 : 0;
		this.dup = dup ? 1 : 0;
	}
}


/**
 * This is a callback function. The client application must provide an
 * implementation of this function to enable asynchronous receipt of
 * messages. The function is registered with the client library by passing
 * it as an argument to MQTTAsync_setCallbacks(). It is called by the client
 * library when a new message that matches a client subscription has been
 * received from the server. This function is executed on a separate thread
 * to the one on which the client application is running.
 * @param context A pointer to the <i>context</i> value originally passed to
 * MQTTAsync_setCallbacks(), which contains any application-specific context.
 * @param topicName The topic associated with the received message.
 * @param topicLen The length of the topic if there are one
 * more NULL characters embedded in <i>topicName</i>, otherwise <i>topicLen</i>
 * is 0. If <i>topicLen</i> is 0, the value returned by <i>strlen(topicName)</i>
 * can be trusted. If <i>topicLen</i> is greater than 0, the full topic name
 * can be retrieved by accessing <i>topicName</i> as a byte array of length
 * <i>topicLen</i>.
 * @param message The MQTTAsync_message structure for the received message.
 * This structure contains the message payload and attributes.
 * @return This function must return a boolean value indicating whether or not
 * the message has been safely received by the client application. Returning
 * true indicates that the message has been successfully handled.
 * Returning false indicates that there was a problem. In this
 * case, the client library will reinvoke MQTTAsync_messageArrived() to
 * attempt to deliver the message to the application again.
 */
extern (C) alias MQTTAsync_messageArrived
	= int function(void *context, char *topicName, int topicLen, MQTTAsync_message *message);

/**
 * This is a callback function. The client application
 * must provide an implementation of this function to enable asynchronous
 * notification of delivery of messages to the server. The function is
 * registered with the client library by passing it as an argument to MQTTAsync_setCallbacks().
 * It is called by the client library after the client application has
 * published a message to the server. It indicates that the necessary
 * handshaking and acknowledgements for the requested quality of service (see
 * MQTTAsync_message.qos) have been completed. This function is executed on a
 * separate thread to the one on which the client application is running.
 * @param context A pointer to the <i>context</i> value originally passed to
 * MQTTAsync_setCallbacks(), which contains any application-specific context.
 * @param token The ::MQTTAsync_token associated with
 * the published message. Applications can check that all messages have been
 * correctly published by matching the tokens returned from calls to
 * MQTTAsync_send() and MQTTAsync_sendMessage() with the tokens passed
 * to this callback.
 */
extern (C) alias MQTTAsync_deliveryComplete
	= void function(void *context, MQTTAsync_token token);

/**
 * This is a callback function. The client application
 * must provide an implementation of this function to enable asynchronous
 * notification of the loss of connection to the server. The function is
 * registered with the client library by passing it as an argument to
 * MQTTAsync_setCallbacks(). It is called by the client library if the client
 * loses its connection to the server. The client application must take
 * appropriate action, such as trying to reconnect or reporting the problem.
 * This function is executed on a separate thread to the one on which the
 * client application is running.
 * @param context A pointer to the <i>context</i> value originally passed to
 * MQTTAsync_setCallbacks(), which contains any application-specific context.
 * @param cause The reason for the disconnection.
 * Currently, <i>cause</i> is always set to NULL.
 */
extern (C) alias MQTTAsync_connectionLost = void function(void *context, char *cause);

/**
 * The data returned on completion of an unsuccessful API call in the response callback onFailure.
 */
struct MQTTAsync_failureData
{
	MQTTAsync_token token;
	int code;
	char *message;
}

/**
 * The data returned on completion of a successful API call in the response callback onSuccess.
 */
struct _N5
{
	MQTTAsync_message message;
	const char *destinationName;
}

struct _N6
{
	const char *serverURI;
	int MQTTVersion;
	int sessionPresent;
}

union _N4
{
	int qos;
	int *qosList;
	_N5 pub;
	_N6 connect;
}

struct MQTTAsync_successData
{
	MQTTAsync_token token;
	_N4 alt;
}

/**
 * This is a callback function. The client application
 * must provide an implementation of this function to enable asynchronous
 * notification of the successful completion of an API call. The function is
 * registered with the client library by passing it as an argument in
 * ::MQTTAsync_responseOptions.
 * @param context A pointer to the <i>context</i> value originally passed to
 * ::MQTTAsync_responseOptions, which contains any application-specific context.
 * @param response Any success data associated with the API completion.
 */
extern (C) alias MQTTAsync_onSuccess
	= void function(void *context, MQTTAsync_successData *response);

/**
 * This is a callback function. The client application
 * must provide an implementation of this function to enable asynchronous
 * notification of the unsuccessful completion of an API call. The function is
 * registered with the client library by passing it as an argument in
 * ::MQTTAsync_responseOptions.
 * @param context A pointer to the <i>context</i> value originally passed to
 * ::MQTTAsync_responseOptions, which contains any application-specific context.
 * @param response Any failure data associated with the API completion.
 */
extern (C) alias MQTTAsync_onFailure
	= void function(void *context, MQTTAsync_failureData *response);

/**
 * Response options.
 */
struct MQTTAsync_responseOptions
{
	immutable char[4] struct_id = "MQTR";
	int struct_version = 0;
	void  function(void *context, MQTTAsync_successData *response)onSuccess;
	void  function(void *context, MQTTAsync_failureData *response)onFailure;
	void *context;
	MQTTAsync_token token;
}


/**
 * This function sets the global callback functions for a specific client.
 * If your client application doesn't use a particular callback, set the
 * relevant parameter to NULL. Any necessary message acknowledgements and
 * status communications are handled in the background without any intervention
 * from the client application.  If you do not set a messageArrived callback
 * function, you will not be notified of the receipt of any messages as a
 * result of a subscription.
 *
 * <b>Note:</b> The MQTT client must be disconnected when this function is
 * called.
 * @param handle A valid client handle from a successful call to
 * MQTTAsync_create().
 * @param context A pointer to any application-specific context. The
 * the <i>context</i> pointer is passed to each of the callback functions to
 * provide access to the context information in the callback.
 * @param cl A pointer to an MQTTAsync_connectionLost() callback
 * function. You can set this to NULL if your application doesn't handle
 * disconnections.
 * @param ma A pointer to an MQTTAsync_messageArrived() callback
 * function.  You can set this to NULL if your application doesn't handle
 * receipt of messages.
 * @param dc A pointer to an MQTTAsync_deliveryComplete() callback
 * function. You can set this to NULL if you do not want to check
 * for successful delivery.
 * @return ::MQTTASYNC_SUCCESS if the callbacks were correctly set,
 * ::MQTTASYNC_FAILURE if an error occurred.
 */
int MQTTAsync_setCallbacks(MQTTAsync handle, void *context,
						   void function(void *context, char *cause) cl,
						   int  function(void *context, char *topicName, int topicLen, MQTTAsync_message *message) ma,
						   void function(void *context, MQTTAsync_token token) dc);


/**
 * This function creates an MQTT client ready for connection to the
 * specified server and using the specified persistent storage (see
 * MQTTAsync_persistence). See also MQTTAsync_destroy().
 * @param handle A pointer to an ::MQTTAsync handle. The handle is
 * populated with a valid client reference following a successful return from
 * this function.
 * @param serverURI A null-terminated string specifying the server to
 * which the client will connect. It takes the form <i>protocol://host:port</i>.
 * <i>protocol</i> must be <i>tcp</i> or <i>ssl</i>. For <i>host</i>, you can
 * specify either an IP address or a host name. For instance, to connect to
 * a server running on the local machines with the default MQTT port, specify
 * <i>tcp://localhost:1883</i>.
 * @param clientId The client identifier passed to the server when the
 * client connects to it. It is a null-terminated UTF-8 encoded string.
 * ClientIDs must be no longer than 23 characters according to the MQTT
 * specification.
 * @param persistence_type The type of persistence to be used by the client:
 * <br>
 * ::MQTTCLIENT_PERSISTENCE_NONE: Use in-memory persistence. If the device or
 * system on which the client is running fails or is switched off, the current
 * state of any in-flight messages is lost and some messages may not be
 * delivered even at QoS1 and QoS2.
 * <br>
 * ::MQTTCLIENT_PERSISTENCE_DEFAULT: Use the default (file system-based)
 * persistence mechanism. Status about in-flight messages is held in persistent
 * storage and provides some protection against message loss in the case of
 * unexpected failure.
 * <br>
 * ::MQTTCLIENT_PERSISTENCE_USER: Use an application-specific persistence
 * implementation. Using this type of persistence gives control of the
 * persistence mechanism to the application. The application has to implement
 * the MQTTClient_persistence interface.
 * @param persistence_context If the application uses
 * ::MQTTCLIENT_PERSISTENCE_NONE persistence, this argument is unused and should
 * be set to NULL. For ::MQTTCLIENT_PERSISTENCE_DEFAULT persistence, it
 * should be set to the location of the persistence directory (if set
 * to NULL, the persistence directory used is the working directory).
 * Applications that use ::MQTTCLIENT_PERSISTENCE_USER persistence set this
 * argument to point to a valid MQTTClient_persistence structure.
 * @return ::MQTTASYNC_SUCCESS if the client is successfully created, otherwise
 * an error code is returned.
 */
int MQTTAsync_create(MQTTAsync *handle, const char *serverURI, const char *clientId,
					 int persistence_type, void *persistence_context);

/**
 * MQTTAsync_willOptions defines the MQTT "Last Will and Testament" (LWT) settings for
 * the client. In the event that a client unexpectedly loses its connection to
 * the server, the server publishes the LWT message to the LWT topic on
 * behalf of the client. This allows other clients (subscribed to the LWT topic)
 * to be made aware that the client has disconnected. To enable the LWT
 * function for a specific client, a valid pointer to an MQTTAsync_willOptions
 * structure is passed in the MQTTAsync_connectOptions structure used in the
 * MQTTAsync_connect() call that connects the client to the server. The pointer
 * to MQTTAsync_willOptions can be set to NULL if the LWT function is not
 * required.
 */
struct MQTTAsync_willOptions
{
	immutable char[4] struct_id = "MQTW";
	int struct_version = 0;
	const(char)* topicName;
	const(char)* message;
	int retained;
	int qos;
}

/**
* MQTTAsync_sslProperties defines the settings to establish an SSL/TLS connection using the
* OpenSSL library. It covers the following scenarios:
* - Server authentication: The client needs the digital certificate of the server. It is included
*   in a store containting trusted material (also known as "trust store").
* - Mutual authentication: Both client and server are authenticated during the SSL handshake. In
*   addition to the digital certificate of the server in a trust store, the client will need its own
*   digital certificate and the private key used to sign its digital certificate stored in a "key store".
* - Anonymous connection: Both client and server do not get authenticated and no credentials are needed
*   to establish an SSL connection. Note that this scenario is not fully secure since it is subject to
*   man-in-the-middle attacks.
*/
struct MQTTAsync_SSLOptions
{
	immutable char[4] struct_id = "MQTS";
	int struct_version = 0;
	const(char)* trustStore;
	const(char)* keyStore;
	const(char)* privateKey;
	const(char)* privateKeyPassword;
	const(char)* enabledCipherSuites;
	int enableServerCertAuth = 1;
}

/**
 * MQTTAsync_connectOptions defines several settings that control the way the
 * client connects to an MQTT server.  Default values are set in
 * MQTTAsync_connectOptions_initializer.
 */
struct MQTTAsync_connectOptions
{
	immutable char[4] struct_id = "MQTC";
	int struct_version = 3;
	int keepAliveInterval = 60;
	int cleansession = 1;
	int maxInflight = 10;
	MQTTAsync_willOptions *will;
	const(char)* username;
	const(char)* password;
	int connectTimeout = 30;
	int retryInterval;
	MQTTAsync_SSLOptions *ssl;
	void  function(void *context, MQTTAsync_successData *response)onSuccess;
	void  function(void *context, MQTTAsync_failureData *response)onFailure;
	void *context;
	int serverURIcount;
	char **serverURIs;
	int MQTTVersion;
	int automaticReconnect = 0;
	int minRetryInterval = 1;
	int maxRetryInterval = 60;
}

/**
  * This function attempts to connect a previously-created client (see
  * MQTTAsync_create()) to an MQTT server using the specified options. If you
  * want to enable asynchronous message and status notifications, you must call
  * MQTTAsync_setCallbacks() prior to MQTTAsync_connect().
  * @param handle A valid client handle from a successful call to
  * MQTTAsync_create().
  * @param options A pointer to a valid MQTTAsync_connectOptions
  * structure.
  * @return ::MQTTASYNC_SUCCESS if the client connect request was accepted.
  * If the client was unable to connect to the server, an error code is
  * returned via the onFailure callback, if set.
  * Error codes greater than 0 are returned by the MQTT protocol:<br><br>
  * <b>1</b>: Connection refused: Unacceptable protocol version<br>
  * <b>2</b>: Connection refused: Identifier rejected<br>
  * <b>3</b>: Connection refused: Server unavailable<br>
  * <b>4</b>: Connection refused: Bad user name or password<br>
  * <b>5</b>: Connection refused: Not authorized<br>
  * <b>6-255</b>: Reserved for future use<br>
  */
int MQTTAsync_connect(MQTTAsync handle, const MQTTAsync_connectOptions *options);


/**
 * Disconnect options.
 */
struct MQTTAsync_disconnectOptions
{
	immutable char[4] struct_id = "MQTD";
	int struct_version = 0;
	int timeout;
	void  function(void *context, MQTTAsync_successData *response)onSuccess;
	void  function(void *context, MQTTAsync_failureData *response)onFailure;
	void *context;
}

/**
 * This function attempts to disconnect the client from the MQTT
 * server. In order to allow the client time to complete handling of messages
 * that are in-flight when this function is called, a timeout period is
 * specified. When the timeout period has expired, the client disconnects even
 * if there are still outstanding message acknowledgements.
 * The next time the client connects to the same server, any QoS 1 or 2
 * messages which have not completed will be retried depending on the
 * cleansession settings for both the previous and the new connection (see
 * MQTTAsync_connectOptions.cleansession and MQTTAsync_connect()).
 * @param handle A valid client handle from a successful call to
 * MQTTAsync_create().
 * @param options The client delays disconnection for up to this time (in
 * milliseconds) in order to allow in-flight message transfers to complete.
 * @return ::MQTTASYNC_SUCCESS if the client successfully disconnects from
 * the server. An error code is returned if the client was unable to disconnect
 * from the server
 */
int MQTTAsync_disconnect(MQTTAsync handle, const MQTTAsync_disconnectOptions *options);


/**
 * This function allows the client application to test whether or not a
 * client is currently connected to the MQTT server.
 * @param handle A valid client handle from a successful call to
 * MQTTAsync_create().
 * @return Boolean true if the client is connected, otherwise false.
 */
int MQTTAsync_isConnected(MQTTAsync handle);

/**
 * This function attempts to subscribe a client to a single topic, which may
 * contain wildcards (see @ref wildcard). This call also specifies the
 * @ref qos requested for the subscription
 * (see also MQTTAsync_subscribeMany()).
 * @param handle A valid client handle from a successful call to
 * MQTTAsync_create().
 * @param topic The subscription topic, which may include wildcards.
 * @param qos The requested quality of service for the subscription.
 * @param response A pointer to a response options structure. Used to set callback functions.
 * @return ::MQTTASYNC_SUCCESS if the subscription request is successful.
 * An error code is returned if there was a problem registering the
 * subscription.
 */
int MQTTAsync_subscribe(MQTTAsync handle, const char *topic, int qos,
						MQTTAsync_responseOptions *response);

/**
 * This function attempts to subscribe a client to a list of topics, which may
 * contain wildcards (see @ref wildcard). This call also specifies the
 * @ref qos requested for each topic (see also MQTTAsync_subscribe()).
 * @param handle A valid client handle from a successful call to
 * MQTTAsync_create().
 * @param count The number of topics for which the client is requesting
 * subscriptions.
 * @param topic An array (of length <i>count</i>) of pointers to
 * topics, each of which may include wildcards.
 * @param qos An array (of length <i>count</i>) of @ref qos
 * values. qos[n] is the requested QoS for topic[n].
 * @param response A pointer to a response options structure. Used to set callback functions.
 * @return ::MQTTASYNC_SUCCESS if the subscription request is successful.
 * An error code is returned if there was a problem registering the
 * subscriptions.
 */
int MQTTAsync_subscribeMany(MQTTAsync handle, int count, char **topic, int *qos,
							MQTTAsync_responseOptions *response);

/**
  * This function attempts to remove an existing subscription made by the
  * specified client.
  * @param handle A valid client handle from a successful call to
  * MQTTAsync_create().
  * @param topic The topic for the subscription to be removed, which may
  * include wildcards (see @ref wildcard).
  * @param response A pointer to a response options structure. Used to set callback functions.
  * @return ::MQTTASYNC_SUCCESS if the subscription is removed.
  * An error code is returned if there was a problem removing the
  * subscription.
  */
// [C] DLLExport int MQTTAsync_unsubscribe(MQTTAsync handle, const char* topic, MQTTAsync_responseOptions* response);
int  MQTTAsync_unsubscribe(MQTTAsync handle, const char *topic, MQTTAsync_responseOptions *response);

/**
  * This function attempts to remove existing subscriptions to a list of topics
  * made by the specified client.
  * @param handle A valid client handle from a successful call to
  * MQTTAsync_create().
  * @param count The number subscriptions to be removed.
  * @param topic An array (of length <i>count</i>) of pointers to the topics of
  * the subscriptions to be removed, each of which may include wildcards.
  * @param response A pointer to a response options structure. Used to set callback functions.
  * @return ::MQTTASYNC_SUCCESS if the subscriptions are removed.
  * An error code is returned if there was a problem removing the subscriptions.
  */
int MQTTAsync_unsubscribeMany(MQTTAsync handle, int count, char **topic,
							  MQTTAsync_responseOptions *response);

/**
  * This function attempts to publish a message to a given topic (see also
  * ::MQTTAsync_sendMessage()). An ::MQTTAsync_token is issued when
  * this function returns successfully. If the client application needs to
  * test for successful delivery of messages, a callback should be set
  * (see ::MQTTAsync_onSuccess() and ::MQTTAsync_deliveryComplete()).
  * @param handle A valid client handle from a successful call to
  * MQTTAsync_create().
  * @param destinationName The topic associated with this message.
  * @param payloadlen The length of the payload in bytes.
  * @param payload A pointer to the byte array payload of the message.
  * @param qos The @ref qos of the message.
  * @param retained The retained flag for the message.
  * @param response A pointer to an ::MQTTAsync_responseOptions structure. Used to set callback functions.
  * This is optional and can be set to NULL.
  * @return ::MQTTASYNC_SUCCESS if the message is accepted for publication.
  * An error code is returned if there was a problem accepting the message.
  */
int MQTTAsync_send(MQTTAsync handle, const char *destinationName,
				   int payloadlen, const void *payload, int qos, int retained,
				   MQTTAsync_responseOptions *response);

/**
  * This function attempts to publish a message to a given topic (see also
  * MQTTAsync_publish()). An ::MQTTAsync_token is issued when
  * this function returns successfully. If the client application needs to
  * test for successful delivery of messages, a callback should be set
  * (see ::MQTTAsync_onSuccess() and ::MQTTAsync_deliveryComplete()).
  * @param handle A valid client handle from a successful call to
  * MQTTAsync_create().
  * @param destinationName The topic associated with this message.
  * @param msg A pointer to a valid MQTTAsync_message structure containing
  * the payload and attributes of the message to be published.
  * @param response A pointer to an ::MQTTAsync_responseOptions structure. Used to set callback functions.
  * @return ::MQTTASYNC_SUCCESS if the message is accepted for publication.
  * An error code is returned if there was a problem accepting the message.
  */
int MQTTAsync_sendMessage(MQTTAsync handle, const char *destinationName,
						  MQTTAsync_message *msg,
						  MQTTAsync_responseOptions *response);

/**
  * This function sets a pointer to an array of tokens for
  * messages that are currently in-flight (pending completion).
  *
  * <b>Important note:</b> The memory used to hold the array of tokens is
  * malloc()'d in this function. The client application is responsible for
  * freeing this memory when it is no longer required.
  * @param handle A valid client handle from a successful call to
  * MQTTAsync_create().
  * @param tokens The address of a pointer to an ::MQTTAsync_token.
  * When the function returns successfully, the pointer is set to point to an
  * array of tokens representing messages pending completion. The last member of
  * the array is set to -1 to indicate there are no more tokens. If no tokens
  * are pending, the pointer is set to NULL.
  * @return ::MQTTASYNC_SUCCESS if the function returns successfully.
  * An error code is returned if there was a problem obtaining the list of
  * pending tokens.
  */
int MQTTAsync_getPendingTokens(MQTTAsync handle, MQTTAsync_token **tokens);

const MQTTASYNC_TRUE = 1;

int MQTTAsync_isComplete(MQTTAsync handle, MQTTAsync_token dt);

int MQTTAsync_waitForCompletion(MQTTAsync handle, MQTTAsync_token dt, uint timeout);


/**
  * This function frees memory allocated to an MQTT message, including the
  * additional memory allocated to the message payload. The client application
  * calls this function when the message has been fully processed. <b>Important
  * note:</b> This function does not free the memory allocated to a message
  * topic string. It is the responsibility of the client application to free
  * this memory using the MQTTAsync_free() library function.
  * @param msg The address of a pointer to the ::MQTTAsync_message structure
  * to be freed.
  */
void MQTTAsync_freeMessage(MQTTAsync_message **msg);

/**
  * This function frees memory allocated by the MQTT C client library, especially the
  * topic name. This is needed on Windows when the client libary and application
  * program have been compiled with different versions of the C compiler.  It is
  * thus good policy to always use this function when freeing any MQTT C client-
  * allocated memory.
  * @param ptr The pointer to the client library storage to be freed.
  */
void MQTTAsync_free(void *ptr);

/**
  * This function frees the memory allocated to an MQTT client (see
  * MQTTAsync_create()). It should be called when the client is no longer
  * required.
  * @param handle A pointer to the handle referring to the ::MQTTAsync
  * structure to be freed.
  */
void MQTTAsync_destroy(MQTTAsync *handle);

enum MQTTASYNC_TRACE_LEVELS
{
	MQTTASYNC_TRACE_MAXIMUM = 1,
	MQTTASYNC_TRACE_MEDIUM,
	MQTTASYNC_TRACE_MINIMUM,
	MQTTASYNC_TRACE_PROTOCOL,
	MQTTASYNC_TRACE_ERROR,
	MQTTASYNC_TRACE_SEVERE,
	MQTTASYNC_TRACE_FATAL,
}


/**
  * This function sets the level of trace information which will be
  * returned in the trace callback.
  * @param level the trace level required
  */
void  MQTTAsync_setTraceLevel(MQTTASYNC_TRACE_LEVELS level);


/**
  * This is a callback function prototype which must be implemented if you want
  * to receive trace information.
  * @param level the trace level of the message returned
  * @param meesage the trace message.  This is a pointer to a static buffer which
  * will be overwritten on each call.  You must copy the data if you want to keep
  * it for later.
  */
extern (C) alias MQTTAsync_traceCallback = void function(MQTTASYNC_TRACE_LEVELS level, char *message);

/**
  * This function sets the trace callback if needed.  If set to NULL,
  * no trace information will be returned.  The default trace level is
  * MQTTASYNC_TRACE_MINIMUM.
  * @param callback a pointer to the function which will handle the trace information
  */
void MQTTAsync_setTraceCallback(void function(MQTTASYNC_TRACE_LEVELS level, char *message)callback);


struct MQTTAsync_nameValue
{
	const(char)* name;
	const(char)* value;
}

/**
  * This function returns version information about the library.
  * no trace information will be returned.  The default trace level is
  * MQTTASYNC_TRACE_MINIMUM
  * @return an array of strings describing the library.  The last entry is a NULL pointer.
  */
MQTTAsync_nameValue* MQTTAsync_getVersionInfo();

