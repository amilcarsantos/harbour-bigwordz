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
	var out = {
		text: '',
		bgText: '',
		append: function(txt, bgTxt) {
			if (bgTxt) {
				if (this.bgText) {
					this.bgText += bgTxt;
				} else {
					this.bgText = this.text + bgTxt;
				}
			} else if (this.bgText) {
				this.bgText += txt;
			}
			this.text += txt;
		}
	};
	var srcBak = {
		text: src,
		bgText: undefined
	};

	var escape	= /([^\*\/_\\#\:]*)/;
	var bold4	= /^\*{4}([\s\S]+?)\*{4}(?!\*)/;
	var bold3	= /^\*{3}([\s\S]+?)\*{3}(?!\*)/;
	var bold2	= /^\*{2}([\s\S]+?)\*{2}(?!\*)/;
	var italic	= /^\/{2}([\s\S]+?)\/{2}(?!\/)/;
	var color	= /^#([\d\w ]+?)#([\s\S]+?)##(?!#)/;
	var colorIdx	= ['00','1C','38','55','71','8E','AA','C6','E3','FF'];
	var blink	= /^\:{2}([\s\S]+?)\:{2}(?!\:)/;
	var underlin	= /^__([\s\S]+?)__(?!_)/;
	var newline	= '\\\\\\';

	try {
		var cap;
		while (src) {

			cap = escape.exec(src);
			if (cap) {
				src = src.substring(cap[0].length);
				out.append(cap[1]);
			}

			if (!src) {
				break;
			}
			switch (src.charAt(0)) {
			case '*':
				cap = bold4.exec(src);
				if (cap) {
					src = src.substring(cap[0].length);
					out.append('<font size="6">' + cap[1] + '</font>');
					continue;
				}
				cap = bold3.exec(src);
				if (cap) {
					src = src.substring(cap[0].length);
					out.append('<font size="5">' + cap[1] + '</font>');
					continue;
				}
				cap = bold2.exec(src);
				if (cap) {
					src = src.substring(cap[0].length);
					out.append('<font size="4">' + cap[1] + '</font>');
					continue;
				}
				break;
			case '\\':
				if (src.indexOf(newline) === 0) {
					src = src.substring(newline.length);
					out.append('<br>');
					continue;
				}
				break;
			case '/':
				cap = italic.exec(src);
				if (cap) {
					src = src.substring(cap[0].length);
					out.append('<i>' + cap[1] + '</i>');
					continue;
				}
				break;
			case '_':
				cap = underlin.exec(src);
				if (cap) {
					src = src.substring(cap[0].length);
					out.append('<u>' + cap[1] + '</u>');
					continue;
				}
				break;
			case ':':
				cap = blink.exec(src);
				if (cap) {
					src = src.substring(cap[0].length);
					out.append(cap[1], '<font color="transparent">' + cap[1] + '</font>');
					continue;
				}
				break;
			case '#':
				cap = color.exec(src);
				if (cap) {
					src = src.substring(cap[0].length);
					var colorVal = cap[1];
					var text = cap[2];
//						print(colorVal);
					if (colorVal.length === 3 && colorVal[0] >= '0' && colorVal[0] <= '9') {
						var colorHash = '#';
						for (var c = 0; c < 3; c++) {
							var idx = colorVal[c] - '0';
							if (idx >= 0 && idx <= 9) {
								colorHash += colorIdx[idx];
							}
						}
						if (colorHash.length === 7) {
							colorVal = colorHash;
						} else {
							colorVal = '';
						}
					} else if (colorVal === 'rnd_ltrs' && text.length <= 24) {
						colorVal = '';
						var textOut = ""
						var code = 32;
						for (var i = 0, t = text.length; i < t; i++) {
							if (text.charAt(i) == ' ') {
								textOut += ' ';
								code = 32;
							} else {
								var colorHash = '#';
								var tc = text.charCodeAt(i);
								colorHash += colorIdx[((tc * (4 + i + code)) % 7) + 3];
								colorHash += colorIdx[((tc * (5 + i + code)) % 7) + 3];
								colorHash += colorIdx[((tc * (2 + i + code)) % 7) + 3];
								textOut += '<font color="' + colorHash + '">' + text.charAt(i) + '</font>';
								code = tc;
							}
						}
						text = textOut;
					}
					if (colorVal) {
						out.append('<font color="' + colorVal + '">' + text + '</font>');
					} else {
						out.append(text);
					}

					continue;
				}
				break;
			default:
				console.error('BUG?',src.charAt(0));
			}

			// not a markup...
			out.append(src.charAt(0));
			src = src.substring(1);
		}
	} catch(e) {
		console.log("error: " + e)
		out = srcBak;
	}
//	print(out.text);
	return out;
}
