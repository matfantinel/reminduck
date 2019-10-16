/*
* Copyright(c) 2011-2019 Matheus Fantinel
*
* This program is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public
* License as published by the Free Software Foundation; either
* version 2 of the License, or(at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* General Public License for more details.
*
* You should have received a copy of the GNU General Public
* License along with this program; if not, write to the
* Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
* Boston, MA 02110-1301 USA
*
* Authored by: Matheus Fantinel <matfantinel@gmail.com>
*/

using Gee;

public class Reminduck.Database {
    private File get_database() {
        return File.new_for_path(get_database_path());
    }

    private string get_database_path() {
        return Path.build_filename(Environment.get_user_data_dir(), "reminduck", "reminduck.db");
    }    

    private void open_database(out Sqlite.Database database) {
        var connection = Sqlite.Database.open(get_database_path(), out database);

        if (connection != Sqlite.OK) {
            stderr.printf("Can't open database: %d: %s\n", database.errcode(), database.errmsg());
        }
    }    

    private void initialize_database() {
        Sqlite.Database db;
        open_database(out db);

        string query = """
            CREATE TABLE `reminders`(
              `description` TEXT NOT NULL,
              `time` TEXT NOT NULL,
              `recurrency_type` INTEGER NULL,
              `recurrency_interval` INTEGER NULL
            );          
        """;

        var exec_query = db.exec(query);

        if (exec_query != Sqlite.OK) {
            print("Couldn't initialize database...\n");
            return;
        }
    }

    public void verify_database() {
        try {
            var path = File.new_build_filename(Environment.get_user_data_dir(), "reminduck");
            if (! path.query_exists() ) {
                path.make_directory_with_parents();
            }

            assert(path.query_exists());
            var database = get_database();
            if (!database.query_exists()) {
                database.create(FileCreateFlags.PRIVATE);
                assert(database.query_exists());
                initialize_database();
            } else {
                this.create_new_columns();
            }
        } catch(Error e) {
             stderr.printf("Error: %s\n", e.message);
        }
    }

    private void create_new_columns() {
        Sqlite.Database db;
        open_database(out db);                

        //create new column (version migration)
        var query = "SELECT recurrency_type FROM 'reminders'";
        var exec_query = db.exec(query);
        if (exec_query != Sqlite.OK) {
            print("Column recurrency_type does not exist. Creating it... \n");
            var alter_table_query = "ALTER TABLE `reminders` ADD `recurrency_type` INTEGER NULL";
            db.exec(alter_table_query);
        }


        query = "SELECT recurrency_interval FROM 'reminders'";
        exec_query = db.exec(query);
        if (exec_query != Sqlite.OK) {
            print("Column recurrency_interval does not exist. Creating it... \n");
            var alter_table_query = "ALTER TABLE `reminders` ADD `recurrency_interval` INTEGER NULL";
            db.exec(alter_table_query);
        }
    }

    public bool upsert_reminder(Reminder reminder) {
        var is_new = reminder.rowid == null;
        var query = "";

        if (is_new) {
            query = """INSERT INTO reminders(description, time, recurrency_type, recurrency_interval)
                        VALUES('"""+ reminder.description +"""',
                        '"""+ reminder.time.to_unix().to_string() +"""',
                        '"""+ ((int)reminder.recurrency_type).to_string() + """',
                        '"""+ reminder.recurrency_interval.to_string() + """')""";
        } else {
            query = """UPDATE reminders
                        SET description = '"""+ reminder.description +"""',
                        time = '"""+ reminder.time.to_unix().to_string() +"""',
                        recurrency_type = '"""+ ((int)reminder.recurrency_type).to_string() +"""',
                        recurrency_interval = '"""+ reminder.recurrency_interval.to_string() +"""'
                        WHERE rowid = """+ reminder.rowid +""";""";
        }
        
        Sqlite.Database db;
        open_database(out db);
        var exec_query = db.exec(query);

        if (exec_query != Sqlite.OK) {
            print("Error executing query:\n%s\n", query);
            return false;
        }

        return true;
    }

    public ArrayList<Reminder> fetch_reminders() {
        var result = new ArrayList<Reminder>();

        var query = """SELECT rowid, description, time, recurrency_type, recurrency_interval
                        FROM reminders
                        ORDER BY time DESC;""";

        Sqlite.Database db;
        open_database(out db);
        string errmsg;

        var exec_query = db.exec(query,(n, v, c) => {
            var reminder = new Reminder();
            reminder.rowid = v[0];
            reminder.description = v[1];
            reminder.time = new GLib.DateTime.from_unix_local(int64.parse(v[2]));

            if (v[3] != null) {
                reminder.recurrency_type = (RecurrencyType)int.parse(v[3]);
            }

            reminder.recurrency_interval = int.parse(v[4]);
                    
            result.add(reminder);
            return 0;
        }, out errmsg);

        if (exec_query != Sqlite.OK) {
            print("Error executing query. Error: \n%s\n", errmsg);
        }

        return result;
    }

    public bool delete_reminder(string row_id) {
        var query = """DELETE FROM reminders WHERE rowid = """+ row_id +""";""";
        
        Sqlite.Database db;
        open_database(out db);
        var exec_query = db.exec(query);

        if (exec_query != Sqlite.OK) {
            print("Error executing query:\n%s\n", query);
            return false;
        }

        return true;
    }
}
