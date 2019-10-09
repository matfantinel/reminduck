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

namespace Reminduck.Widgets.Views {
    public class RemindersView : Gtk.Box {
        public signal void add_request();
        public signal void edit_request(Reminder reminder);
        public signal void reminder_deleted();

        Gtk.Label title;
        Gtk.ListBox reminders_list;        

        construct {
            orientation = Gtk.Orientation.VERTICAL;
        }

        public RemindersView() {
            this.build_ui();
        }
        
        public void build_ui() {
            this.margin = 15;
            
            var box = new Gtk.Box(Gtk.Orientation.VERTICAL, 5);
            box.margin = 10;

            this.title = new Gtk.Label(_("Your reminders"));
            this.title.get_style_context().add_class("h2");
            
            box.pack_start(this.title, true, false, 0);

            var add_new_button = new Gtk.Button.with_label(_("Create another"));
            add_new_button.halign = Gtk.Align.CENTER;
            add_new_button.get_style_context().add_class("suggested-action");
            add_new_button.activate.connect(add_reminder);
            add_new_button.clicked.connect(add_reminder);

            box.pack_start(add_new_button, false, false, 0);

            pack_start(box, false, false, 0);

            var scrolled_window = new Gtk.ScrolledWindow(null, null);
            build_reminders_list();
            scrolled_window.add_with_viewport(this.reminders_list);

            pack_start(scrolled_window, true, true, 0);
        }

        public void add_reminder() {
            add_request();
        }

        public void build_reminders_list() {        
            if (this.reminders_list == null) {
                this.reminders_list = new Gtk.ListBox();
                this.reminders_list.get_style_context().add_class("reminduck-reminders-list");
            } else {
                foreach(var child in this.reminders_list.get_children()) {
                    this.reminders_list.remove(child);
                }
            }
            
            var index = 0;
            foreach(var reminder in ReminduckApp.reminders) {
                var box = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 5);
                box.margin = 2;
                box.get_style_context().add_class("list-item");

                var description = new Gtk.Label(reminder.description);
                description.wrap = true;
                description.single_line_mode = false;

                box.pack_start(description, false, false, 0);

                var delete_button = new Gtk.Button.from_icon_name("edit-delete");
                delete_button.activate.connect(() => { on_delete(reminder); } );
                delete_button.clicked.connect(() => { on_delete(reminder); } );

                box.pack_end(delete_button, false, false, 0);
                
                var edit_button = new Gtk.Button.from_icon_name("edit");
                edit_button.activate.connect(() => { on_edit(reminder); } );
                edit_button.clicked.connect(() => { on_edit(reminder); } );

                box.pack_end(edit_button, false, false, 5);
                
                box.pack_end(new Gtk.Label(reminder.time.format("%x") + " " + reminder.time.format("%X")), false, false, 0);

                var row = new Gtk.ListBoxRow();
                row.add(box);

                this.reminders_list.insert(row, index);
            }
            index++;

            this.reminders_list.show_all();
        }

        private void on_delete(Reminder reminder) {
            ReminduckApp.database.delete_reminder(reminder.rowid);
            this.reminder_deleted();
        }

        private void on_edit(Reminder reminder) {
            this.edit_request(reminder);
        }
    }
}
