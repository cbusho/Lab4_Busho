/*
 * main.c
 *
 *  Created on: Mar 31, 2014
 *      Author: C15Colin.Busho
 */

#include <xuartlite_l.h>
#include <xparameters.h>
#include <xil_io.h>


int main(void)
{
 while (1)
 {
	 unsigned char c, d, e;
	 c = 0x00;
	 d = 0x00;
	 e = 0x00;

	 while(c == 0x00){
		 c = XUartLite_RecvByte(0x84000000); //receive letter
	 }
	 XUartLite_SendByte(0x84000000, c);

	 while(d == 0x00){
		 d = XUartLite_RecvByte(0x84000000); //receive letter
	 }
	 XUartLite_SendByte(0x84000000, d);

	 while(e == 0x00){
		 e = XUartLite_RecvByte(0x84000000); //receive letter
	 }
	 XUartLite_SendByte(0x84000000, e);
	 XUartLite_SendByte(0x84000000, 0x20);	 //send space char

	 //led command
	 if((c == 0x6C) && (d == 0x65) && (e == 0x64)){
		 c = 0x00;
		 d = 0x00;
		 e = 0x00;

		 while(c == 0x00){
		 	 c = XUartLite_RecvByte(0x84000000) - 0x30; //receive letter
		 	 d = c - 0x27;
		 	 if((c >= 0x0) && (c <= 0x9)){
		 		 e = c;
		 	 }
		 	 else if((d >= 0xA) && (d <= 0xF)){
		 		 e = d;
		 	 }
		 	 else{
		 		 e = 0x0;
		 	 }
		 }
		 XUartLite_SendByte(0x84000000, c + 0x30);
		 e = e << 4;

		 c = 0x00;
		 d = 0x00;

		 while(c == 0x00){
			 c = XUartLite_RecvByte(0x84000000) - 0x30; //receive letter
			 d = c - 0x27;
			 if((c >= 0x0) && (c <= 0x9)){
				 e += c;
			 }
			 else if((d >= 0xA) && (d <= 0xF)){
				 e += d;
			 }
			 else{
				 e = e;
			 }
		 }
		 XUartLite_SendByte(0x84000000, c + 0x30);
		 Xil_Out8(0x83000000, e);

	 }

	 //switch command
	 if((c == 0x73) && (d == 0x77) && (e == 0x74)){
		 c = 0x00;
		 d = 0x00;
		 e = 0x00;

		 c = Xil_In8(0x83000004) & 0xF;
		 d = Xil_In8(0x83000004) & 0xF0;

		 d = d >> 4;

		 if(c <= 0x9){
			 c = c + 0x30;
		 }
		 else{
			 c = c + 0x57;
		 }

		 if(d <= 0x9){
			 d = d + 0x30;
		 }
		 else{
			 d = d + 0x57;
		 }

		 XUartLite_SendByte(0x84000000, d);
		 XUartLite_SendByte(0x84000000, c);

	 }

	 XUartLite_SendByte(0x84000000, 0xA);	 //send new line char
	 XUartLite_SendByte(0x84000000, 0xD);	 //send return char

 }

 return 0;
}
