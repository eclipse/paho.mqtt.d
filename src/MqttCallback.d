/////////////////////////////////////////////////////////////////////////////
/// @file MqttCallback.d
/// Interface for callbacks from asynchronous MQTT events.
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

import MqttMessage;
import MqttToken;

/////////////////////////////////////////////////////////////////////////////

/**
 * Provides a mechanism for tracking the completion of an asynchronous
 * action.
 */
interface MqttCallback
{
	/**
	 * This method is called when the connection to the server is lost.
	 * @param cause A possible explanation of why the connection was lost.
	 */
	void connectionLost(const string cause);
	/**
	 * This method is called when a message arrives from the server.
	 * @param topic The topic on which the message was published.
	 * @param msg The message that was received.
	 */
	void messageArrived(const string topic, immutable MqttMessage msg);
	/**
	 * Called when delivery for a message has been completed, and all
	 * acknowledgments have been received.
	 * @param token The integer message identifier.
	 */
	void deliveryComplete(MqttDeliveryToken tok);
};

