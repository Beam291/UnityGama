/**
* Name: NetworkConnect
* Based on the internal empty template. 
* Author: Beam291
* Tags: 
*/


model NetworkConnect

global skills: [network]{
	unknown client <- nil;
	
	init{
		do connect protocol: "tcp_server" port: 8052 raw: true;	
	}
	
	reflex send {
		do send to: client contents: "stuff";
	}
	
	reflex receive when: has_more_message() {
		loop while: has_more_message() {
			message mm <- fetch_message();
			write name + " received : " + mm.contents ;
			client <- mm.sender;
		}

	}
}

experiment e{
	output{
		
	}
}
/* Insert your model definition here */

