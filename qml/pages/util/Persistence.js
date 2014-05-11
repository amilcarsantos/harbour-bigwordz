//Persistence.js
.import QtQuick.LocalStorage 2.0 as PersistenceLS

// First, let's create a short helper function to get the database connection
function database() {
	return PersistenceLS.LocalStorage.openDatabaseSync("bigwordz", "1.0", "PersistenceDatabase", 100000);
}

// At the start of the application, we can initialize the tables we need if they haven't been created yet
function initialize() {
	database().transaction(
		function(tx,er) {
			// Create the settings table if it doesn't already exist
			tx.executeSql('CREATE TABLE IF NOT EXISTS settings(setting TEXT, value TEXT)');
			// Create the 'storedWords' table if it doesn't already exist
			tx.executeSql('CREATE TABLE IF NOT EXISTS storedWords(words TEXT, lastUsage DATETIME DEFAULT CURRENT_TIMESTAMP)');

			tx.executeSql('CREATE TABLE IF NOT EXISTS favoriteWords(id INTEGER PRIMARY KEY AUTOINCREMENT, words TEXT, colorScheme TEXT)');
		});
}


function setting(settingName, defaultValue) {
	var value = defaultValue
	database().readTransaction(function(tx) {
		var rs = tx.executeSql('SELECT * FROM settings WHERE setting=?', [settingName])
		if (rs.rows.length > 0) {
			value = rs.rows.item(0).value
		}
	});
//	console.log("setting '" + settingName + "' value: " + value);
	return value;
}

function stringToBoolean(str) {
	switch(str.toString().toLowerCase()) {
	case "true": case "yes": case "1":
		return true;
	case "false": case "no": case "0": case null:
		return false;
	default:
		return Boolean(string);
	}
}

function settingBool(settingName, defaultValue) {
	var value = setting(settingName, defaultValue)
	return stringToBoolean(value);
}

function settingInt(settingName, defaultValue) {
	var value = setting(settingName, defaultValue)
	return parseInt(value, 10);
}

// This function is used to update settings into the database
function setSetting(settingName, value) {
	var res = "";
	database().transaction(function(tx) {
		res = "OK";
		var stringValue = value.toString();
		var rs = tx.executeSql('UPDATE settings SET value=? WHERE setting=?', [stringValue, settingName]);
		if (rs.rowsAffected === 0) {
			rs = tx.executeSql('INSERT OR REPLACE INTO settings VALUES (?,?);', [settingName, stringValue]);
			if (rs.rowsAffected === 0) {
				res = "Error";
			}
		}
	});
	// The function returns "OK" if it was successful, or "Error" if it wasn't
//	console.log("setSetting '" + setting + "' result: " + res);
	return res;
}

function populateStoredWords(model) {
	database().readTransaction(function(tx) {
		var rs = tx.executeSql('SELECT * FROM storedWords ORDER BY lastUsage DESC');
		for (var i = 0; i < rs.rows.length; i++) {
			model.append({ "text": rs.rows.item(i).words });
		}
	});
}

function persistStoredWord(text) {
	var res = "";
	database().transaction(function(tx) {
		res = "OK";
		var rs = tx.executeSql('INSERT OR REPLACE INTO storedWords (words) VALUES (?)', [text]);
		if (rs.rowsAffected === 0) {
			res = "Error";
		}
	});
//	console.log("persistStoredWord '" + currentText + "' result: " + res);
	return res;
}

function updateStoredWordUsage(text) {
	database().transaction(function(tx) {
		tx.executeSql('UPDATE storedWords SET lastUsage = datetime(\'NOW\') WHERE words=?', [text]);
	});
}

function removeStoredWord(text) {
	var res = "";
	database().transaction(function(tx) {
		res = "OK";
		var rs = tx.executeSql('DELETE FROM storedWords WHERE words=?', [text]);
		if (rs.rowsAffected === 0) {
			res = "Error";
		}
	});
//	console.log("removeStoredWord '" + currentText + "' result: " + res);
	return res;
}

function removeAllStoredWords() {
	var res = "";
	database().transaction(function(tx) {
		res = "OK";
		var rs = tx.executeSql('DELETE FROM storedWords');
		if (rs.rowsAffected === 0) {
			res = "Error";
		}
	});
//	console.log("removeAllStoredWords() res: ", res);
	return res;
}


function populateFavoriteWords(model) {
	database().readTransaction(function(tx) {
		var rs = tx.executeSql('SELECT * FROM favoriteWords ORDER BY id');
		for (var i = 0; i < rs.rows.length; i++) {
			model.append({ "text": rs.rows.item(i).words });
		}
	});
}

function addFavoriteWord(text) {
	database().transaction(function(tx) {
		tx.executeSql('INSERT INTO favoriteWords (words) VALUES (?)', [text]);
	});
}

function removeFavoriteWord(text) {
	var res = "";
	database().transaction(function(tx) {
		res = "OK";
		var rs = tx.executeSql('DELETE FROM favoriteWords WHERE words = ?', [text]);
		if (rs.rowsAffected === 0) {
			res = "Error";
		}
	});
//	console.log("removeFavoriteWord() res: ", res);
	return res;
}

function removeAllFavoriteWords() {
	var res = "";
	database().transaction(function(tx) {
		res = "OK";
		var rs = tx.executeSql('DELETE FROM favoriteWords');
		if (rs.rowsAffected === 0) {
			res = "Error";
		}
	});
//	console.log("removeAllFavoriteWords() res: ", res);
	return res;
}
