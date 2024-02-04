// thr_sub.d
//
// Eclipse Paho D Library sample application for subscribing using a thread
// to process incoming messages.
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

import MqttAsyncClient;
import MqttMessage;
import MqttToken;
import MqttException;
import MqttCallback;
import MqttActionListener;

import std.stdio;
import std.concurrency;
import std.typecons;
import core.thread;

/////////////////////////////////////////////////////////////////////////////

// Thread function to receive and process incoming messages.
// The client will send messages to us as they arrive with a tuple
// containing the string topic and a rebinable reference to an immutable
// message.

void msgThreadFunc()
{
	bool run = true;
	writeln("Started message thread.");

	while (run) {
		receive(
			(string topic, Rebindable!(immutable(MqttMessage)) msg) {
				string s = msg.getPayloadStr();
				writefln("%s: %s", topic, s);
			},
			(OwnerTerminated ot) { run = false; }
		);
	}
};

/////////////////////////////////////////////////////////////////////////////

int main()
{
	const int		QOS = 1;
	const string	HOST = "tcp://localhost:1883";
	const string	CLIENT_ID = "thr_sub.d.client";

	writeln("Eclipse Paho MQTT D library sample thread subscriber\n");

	try {
		auto cli = new MqttAsyncClient(HOST, CLIENT_ID);

		if (!cli.isOK()) {
			writeln("Error creating client.");
			return 1;
		}

		// Create a thread to receive incoming messages
		Tid msgTid = spawn(&msgThreadFunc);
		cli.setMessageThread(msgTid);

		writeln("Connecting...");
		MqttToken tok = cli.connect();
		tok.waitForCompletion();
		writeln("...OK");

		writeln("Subscribing...");
		cli.subscribe("hello", QOS).waitForCompletion();
		writeln("...OK");

		Thread.sleep(30.seconds());

		writeln("\nDisconnecting...");
		tok = cli.disconnect();
		tok.waitForCompletion();
		writeln("...OK\n\nDone");

		return 0;
	}
	catch (MqttException exc) {
		writeln("MQTT Error: ", exc.getReasonCode());
	}

	return 1;
}

