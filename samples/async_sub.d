// async_sub.d
//
// Eclipse Paho D Library sample application for subscribing.
//

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

// Compile with:
//		gdc-4.9 -o AsyncSubscribe AsyncPublisher.d  AsyncClient.d MQTTAsync.d \
// 			~/mqtt/org.eclipse.paho.mqtt.c/build/output/libpaho-mqtt3a.so
//

import MqttAsyncClient;
import MqttMessage;
import MqttToken;
import MqttException;
import MqttCallback;
import MqttActionListener;

import std.stdio;
import core.thread;

/////////////////////////////////////////////////////////////////////////////

/**
 * Override an MqttCallback interface to get messages as they arrive.
 */
class Callback : MqttCallback
{
	override void connectionLost(const string cause) {}

	override void messageArrived(const string topic, immutable MqttMessage msg) {
		string s = msg.getPayloadStr();
		writefln("%s: %s", topic, s);
	}

	override void deliveryComplete(MqttDeliveryToken tok) {}
};

/////////////////////////////////////////////////////////////////////////////

int main()
{
	const int		QOS = 1;
	const string	HOST = "tcp://localhost:1883";
	const string	CLIENT_ID = "async_sub.d.client";

	writeln("Eclipse Paho MQTT D library sample subscriber\n");

	try {
		auto cli = new MqttAsyncClient(HOST, CLIENT_ID);

		if (!cli.isOK()) {
			writeln("Error creating client.");
			return 1;
		}

		cli.setCallback(new Callback);

		write("Connecting...");
		stdout.flush();
		MqttToken tok = cli.connect();
		tok.waitForCompletion();
		writeln("OK");

		write("Subscribing...");
		stdout.flush();
		tok = cli.subscribe("hello", QOS);
		tok.waitForCompletion();
		writeln("OK");

		Thread.sleep(60.seconds());

		write("\nDisconnecting...");
		stdout.flush();
		tok = cli.disconnect();
		tok.waitForCompletion();
		writeln("OK\nDone");

		return 0;
	}
	catch (MqttException exc) {
		writeln("MQTT Error: ", exc.getReasonCode());
	}

	return 1;
}

