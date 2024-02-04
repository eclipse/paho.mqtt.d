# Eclipse Paho MQTT D client library

**This project is no longer maintained.**

This repository contains the source code for the [Eclipse Paho](http://eclipse.org/paho) MQTT D client library on memory-managed operating systems such as Linux/Posix and Windows.

*Note that this library is currenly in an early incubation phase. Although the code is operational, the overall project is lacking in essentials such as a complete implementation, proper documentation, and basic testing.*

This code builds a library which enables D applications to connect to an [MQTT](http://mqtt.org) broker to publish messages, and to subscribe to topics and receive published messages.

Currently only asynchronous modes of operation are supported.

This code requires the [Paho C library](https://github.com/eclipse/paho.mqtt.c) by Ian Craggs

## Building from source

The library uses the D lang build tool, DUB. It can be downloaded from the [DUB download page](https://code.dlang.org/download).

Simply clone the package repository and run `dub`.

```
$ git clone https://github.com/eclipse/paho.mqtt.d.git
$ cd paho.mqtt.d
$ dub
```

## Example

Sample applications can be found in the `samples` subdirectory.

```
int main()
{
	const int QOS = 1;

	try {
		auto cli = new MqttAsyncClient("tcp://localhost:1883", "AsyncClient.d");

		if (!cli.isOK()) {
			writeln("Error creating client.");
			return 1;
		}

		writeln("Connecting...");
		auto connListener = new ConnListener;
		MqttToken tok = cli.connect(null, null, connListener);
		tok.waitForCompletion();
		writeln("...OK");

		writeln("Sending a message...");
		stdout.flush();
		MqttDeliveryToken dtok = cli.publish("hello", "Hello World", QOS, false);
		dtok.waitForCompletion();

		writeln("...OK\nSending another message...");
		auto msg = new MqttMessage("Hi There", QOS);
		dtok = cli.publish("hello", msg);
		dtok.waitForCompletion();

		writeln("...OK\nDisconnecting...");
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
```

-----------

The API organization and documentation were adapted from the Paho Java library
by Dave Locke.
Copyright (c) 2012, IBM Corp

 All rights reserved. This program and the accompanying materials
 are made available under the terms of the Eclipse Public License v1.0
 which accompanies this distribution, and is available at
 http://www.eclipse.org/legal/epl-v10.html

-----------

This code requires the Paho C library by Ian Craggs
Copyright (c) 2013 IBM Corp.

 All rights reserved. This program and the accompanying materials
 are made available under the terms of the Eclipse Public License v1.0
 and Eclipse Distribution License v1.0 which accompany this distribution. 

 The Eclipse Public License is available at 
    http://www.eclipse.org/legal/epl-v10.html
 and the Eclipse Distribution License is available at 
   http://www.eclipse.org/org/documents/edl-v10.php.

