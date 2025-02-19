Resource Loader

Description

Resource Loader is a Lua script for FiveM that scans, reads, and interprets server resource files (fxmanifest.lua and _resource.lua). It manages dependencies between resources, verifies files, and records information in a database via oxmysql. A logging system is also included to facilitate tracking and debugging.

Features

🔍 Automatic scan of resources at server startup.

📂 Reading of fxmanifest.lua and _resource.lua files.

📑 Sorting files based on their type (server_script, client_script, shared_script).

🔄 Dependency verification between resources.

🚫 Detection and exclusion of obfuscated or malicious scripts.

🛠 Saving information to a database via oxmysql.

📝 Log management in logs.txt and console display.

♻ Automatic purging of obsolete database entries.

Requirements

🛠 FiveM (FXServer) installed.

📦 oxmysql configured and functional.

🗃 Accessible MySQL database.

📜 Resources with fxmanifest.lua or _resource.lua.

Installation

Clone this repository to your FiveM server:

git clone https://github.com/krigsexe/fivem-devscan.git

Move the script to the resources/ folder:

mv resource_loader /path/to/FXServer/resources/

Add ensure resource_loader to server.cfg.

Set up the database by importing the provided SQL query.

Database Configuration

Run this SQL query to create the necessary table:

CREATE TABLE IF NOT EXISTS `resources` (
    `id` INT(11) NOT NULL AUTO_INCREMENT,
    `name` VARCHAR(100) NOT NULL,
    `dependencies` TEXT NULL,
    `scripts` TEXT NULL,
    `last_updated` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`)
);

Logs

Logs are saved in logs.txt and displayed in the console. They include:

📢 INFO: General information.

✅ SUCCESS: Successful actions.

⚠ WARNING: Detected issues (missing dependencies, obfuscated scripts, etc.).

❌ ERROR: Critical errors.

Next Steps

📌 Performance improvements for faster scanning.

🔄 Addition of a resource management interface.

🛡 Enhanced security for executed scripts.

Contribution

Contributions are welcome! Fork the project, suggest improvements, or fix bugs.

License

This project is under the MIT license. Free and open use.

🚀 Developed to facilitate resource management on FiveM!

