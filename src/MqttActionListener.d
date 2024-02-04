/////////////////////////////////////////////////////////////////////////////
/// @file MqttActionListener.d
/// Interface for callbacks from asynchronous MQTT actions.
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

import MqttToken;

/////////////////////////////////////////////////////////////////////////////

/**
 * Interface for notification callbacks when an asynchronous action
 * completes.
 *
 * A listener is registered on an MqttToken and a token is associated with
 * an action like connect or publish. When used with tokens on the
 * MqttAsyncClient the listener will be called back on the MQTT client's
 * thread. The listener will be informed if the action succeeds or fails.
 * It is importantthat the listener returns control quickly otherwise the
 * operation of the MQTT client will be stalled.
 */
interface IMqttActionListener
{
	/**
	 * This method is invoked when an action has completed
	 * successfully.
	 * @param tok The tokent associated with the action.
	 */
	void onSuccess(IMqttToken tok);
	/**
	 * This method is invoked when an action fails.
	 * @param tok The token associated with the action
	 * @param exc
	 */
	void onFailure(IMqttToken tok, Throwable exc);
}

