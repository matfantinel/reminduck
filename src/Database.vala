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
    private string get_database_path() {
        return Environment.get_home_dir() + "/.local/share/com.github.matfantinel.reminduck/database.db";
    }    

    private File get_database() {
        return File.new_for_path(get_database_path());
    } 

    private void open_database(out Sqlite.Database database) {
        var connection = Sqlite.Database.open(get_database_path(), out database);

        if (connection != Sqlite.OK) {
            stderr.printf("Can't open database: %d: %s\n", database.errcode(), database.errmsg());
            Gtk.main_quit();
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

        db.exec(query);
    }

    public void verify_database() {
        try {
            var path = File.new_build_filename(Environment.get_home_dir() + "/.local/share/com.github.matfantinel.reminduck");
            if (! path.query_exists() ) {
                path.make_directory_with_parents();
            }

            assert(path.query_exists());
            var database = get_database();
            if (!database.query_exists()) {
                database.create(FileCreateFlags.PRIVATE);
                assert(database.query_exists());
                initialize_database();
            } 
            //  else {
            //      this.create_new_columns();
            //  }
        } catch(Error e) {
             stderr.printf("Error: %s\n", e.message);
        }
    }

    //  private void create_new_columns() {
    //      Sqlite.Database db;
    //      open_database(out db);                

    //      //create new column (version migration)
    //      var query = "SELECT recurrency_type FROM 'reminders'";
    //      var exec_query = db.exec(query);
    //      if (exec_query != Sqlite.OK) {
    //          print("Column recurrency_type does not exist. Creating it... \n");
    //          var alter_table_query = "ALTER TABLE `reminders` ADD `recurrency_type` INTEGER NULL";
    //          db.exec(alter_table_query);
    //      }


    //      query = "SELECT recurrency_interval FROM 'reminders'";
    //      exec_query = db.exec(query);
    //      if (exec_query != Sqlite.OK) {
    //          print("Column recurrency_interval does not exist. Creating it... \n");
    //          var alter_table_query = "ALTER TABLE `reminders` ADD `recurrency_interval` INTEGER NULL";
    //          db.exec(alter_table_query);
    //      }
    //  }

    public bool upsert_reminder(Reminder reminder) {
        var is_new = reminder.rowid == null;
        string prepared_query_str = "";
        
        if (is_new) {
            prepared_query_str = "INSERT INTO reminders(description, time, recurrency_type, recurrency_interval) 
                                        VALUES($DESCRIPTION, $TIME, $RECURRENCY_TYPE, $RECURRENCY_INTERVAL)";
        } else {
            prepared_query_str = "UPDATE reminders 
                SET description = $DESCRIPTION, time = $TIME, recurrency_type = $RECURRENCY_TYPE, recurrency_interval = $RECURRENCY_INTERVAL
                WHERE rowid = $ROWID";
        }
        
        Sqlite.Database db;
        open_database(out db);

        Sqlite.Statement stmt;

        int exec_query = db.prepare_v2(prepared_query_str, prepared_query_str.length, out stmt);

        if (exec_query != Sqlite.OK) {
            print("Error executing query:\n%s\n", prepared_query_str);
            return false;
        }

        int param_position = stmt.bind_parameter_index ("$DESCRIPTION");
        assert (param_position > 0);
        stmt.bind_text (param_position, reminder.description);

        param_position = stmt.bind_parameter_index ("$TIME");
        assert (param_position > 0);
        stmt.bind_text (param_position, reminder.time.to_unix().to_string());

        param_position = stmt.bind_parameter_index ("$RECURRENCY_TYPE");
        assert (param_position > 0);
        stmt.bind_text (param_position, ((int)reminder.recurrency_type).to_string());

        param_position = stmt.bind_parameter_index ("$RECURRENCY_INTERVAL");
        assert (param_position > 0);
        stmt.bind_text (param_position, reminder.recurrency_interval.to_string());

        if (!is_new) {
            param_position = stmt.bind_parameter_index ("$ROWID");
            assert (param_position > 0);
            stmt.bind_text (param_position, reminder.rowid);
        }

        exec_query = stmt.step();
        if (exec_query != Sqlite.DONE) {
            print("Error executing query:\n%s\n", db.errmsg());
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
