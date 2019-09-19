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

namespace Reminduck.Widgets.Views {
    public class RemindersView : Gtk.Box {
        public signal void add_request ();
        public signal void edit_request (Reminder reminder);
        public signal void app_deleted ();

        Gtk.Label title;
        Gtk.ListBox reminders_list;        

        construct {
            orientation = Gtk.Orientation.VERTICAL;
        }

        public RemindersView () {
            this.build_ui ();
        }
        
        public void build_ui () {
            this.margin = 15;
            
            this.title = new Gtk.Label (_("Your reminders"));
            this.title.get_style_context().add_class("h2");
            
            pack_start(this.title, true, false, 0);

            build_reminders_list ();

            pack_start(this.reminders_list, true, false, 0);

            this.show_all();
        }

        public void add_reminder () {
            add_request ();
        }

        public void build_reminders_list () {        
            if (this.reminders_list == null) {
                this.reminders_list = new Gtk.ListBox ();
            } else {
                foreach (var child in this.reminders_list.get_children ()) {
                    this.reminders_list.remove (child);
                }
            }
            
            var index = 0;
            foreach (var reminder in ReminduckApp.reminders) {
                var box = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 5);
                box.margin = 5;
                box.pack_start (new Gtk.Label (reminder.description), false, false, 0);
                box.pack_end (new Gtk.Label (reminder.time.to_string()), false, false, 0);

                var row = new Gtk.ListBoxRow ();
                row.add (box);

                this.reminders_list.insert (row, index);
                index++;
            }

            this.reminders_list.show_all ();
        }
    }
}
