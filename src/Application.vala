/*
* Copyright (c) 2011-2019 Matheus Fantinel
*
* This program is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public
* License as published by the Free Software Foundation; either
* version 2 of the License, or (at your option) any later version.
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

namespace Reminduck {

    public class ReminduckApp : Granite.Application {

        construct {
            application_id = "com.github.matfantinel.reminduck";
            flags = ApplicationFlags.FLAGS_NONE;
            database = new Reminduck.Database();
        }

        static ReminduckApp _instance = null;

        public static ArrayList<Reminder> reminders;

        public static ReminduckApp instance {
            get {
                if (_instance == null)
                    _instance = new ReminduckApp ();
                return _instance;
            }
        }

        public Gtk.Window main_window { get; private set; default = null; }
        public static Reminduck.Database database;

        protected override void activate () {
            database.verify_database ();
            
            if (main_window != null) {
                main_window.present ();
                return;
            }
            reload_reminders ();

            main_window = new MainWindow ();
            main_window.set_application (this);
        }        

        public static int main(string[] args) {
            var app = new ReminduckApp ();
            return app.run (args);
        }

        public static void reload_reminders () {
            reminders = database.fetch_reminders ();
        }
    }
}