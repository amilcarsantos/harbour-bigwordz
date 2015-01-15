/*
  Copyright (C) 2014 Amilcar Santos
  Contact: Amilcar Santos <amilcar.santos@gmail.com>
  All rights reserved.

  You may use this file under the terms of BSD license as follows:

  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions are met:
	* Redistributions of source code must retain the above copyright
	  notice, this list of conditions and the following disclaimer.
	* Redistributions in binary form must reproduce the above copyright
	  notice, this list of conditions and the following disclaimer in the
	  documentation and/or other materials provided with the distribution.
	* Neither the name of the Amilcar Santos nor the
	  names of its contributors may be used to endorse or promote products
	  derived from this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR CONTRIBUTORS BE LIABLE FOR
  ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

.pragma library

function marked(src) {
	var out = "";
	var srcBak = src;

	var escape	= /([^\*\/_\\]*)/;
	var bold4	= /^\*\*\*\*([\s\S]+?)\*\*\*\*(?!\*)/;
	var bold3	= /^\*\*\*([\s\S]+?)\*\*\*(?!\*)/;
	var bold2	= /^\*\*([\s\S]+?)\*\*(?!\*)/;
	var italic	= /^\/\/([\s\S]+?)\/\/(?!\/)/;
	var underlin = /^__([\s\S]+?)__(?!_)/;
	var newline = "\\\\\\";

	try {
		var cap;
		while (src) {

			cap = escape.exec(src);
			if (cap) {
				src = src.substring(cap[0].length);
				out += cap[1];
			}

			if (src) {
				if (src.charAt(0) === '*') {
					cap = bold4.exec(src);
					if (cap) {
						src = src.substring(cap[0].length);
						out +=  '<font size="6">' + cap[1] + '</font>';
						continue;
					}
					cap = bold3.exec(src);
					if (cap) {
						src = src.substring(cap[0].length);
						out +=  '<font size="5">' + cap[1] + '</font>';
						continue;
					}
					cap = bold2.exec(src);
					if (cap) {
						src = src.substring(cap[0].length);
						out +=  '<font size="4">' + cap[1] + '</font>';
						continue;
					}
				} else {
//					print(src);
					if (src.indexOf(newline) === 0) {
						src = src.substring(newline.length);
						out += "<br>";
						continue;
					}
					cap = italic.exec(src);
					if (cap) {
						src = src.substring(cap[0].length);
						out +=  '<i>' + cap[1] + '</i>';
						continue;
					}
					cap = underlin.exec(src);
					if (cap) {
						src = src.substring(cap[0].length);
						out +=  '<u>' + cap[1] + '</u>';
						continue;
					}
				}

				// not a markup...
				out += src.charAt(0);
				src = src.substring(1);
			}
		}
	} catch(e) {
		console.log("error: " + e)
		out = srcBak;
	}
//	print(out);
	return out;
}
