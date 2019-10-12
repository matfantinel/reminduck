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

namespace Reminduck.Widgets.Views {
    public class ReminderEditor : Gtk.Box {
        public signal void reminder_created();
        public signal void reminder_edited();

        Gtk.Label title;
        Gtk.Entry reminder_input;
        Granite.Widgets.DatePicker date_picker;
        Granite.Widgets.TimePicker time_picker;

        Gtk.Switch recurrency_switch;
        Gtk.Box recurrency_container;
        Gtk.ComboBox recurrency_combobox;
        Gtk.Button save_button;

        Reminder reminder;

        bool touched;        
        
        construct {
            orientation = Gtk.Orientation.VERTICAL;
            this.reminder = new Reminder();
        }

        public ReminderEditor() {
            this.build_ui();
        }

        private void build_ui() {
            this.margin = 15;

            this.title = new Gtk.Label(_("Create a new reminder"));
            this.title.get_style_context().add_class("h2");

            this.reminder_input = new Gtk.Entry();
            this.reminder_input.placeholder_text = _("What do you want to be reminded of?");
            this.reminder_input.show_emoji_icon = true;
            
            this.date_picker = new Granite.Widgets.DatePicker.with_format(
                Granite.DateTime.get_default_date_format(false, true, true)
            );

            this.time_picker = new Granite.Widgets.TimePicker.with_format(
                Granite.DateTime.get_default_time_format(true), 
                Granite.DateTime.get_default_time_format(false)
            );




            this.recurrency_switch = new Gtk.Switch();

            var recurrency_switch_container = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 5);
            recurrency_switch_container.margin = 2;

            recurrency_switch_container.pack_end(this.recurrency_switch, false, false, 0);
            recurrency_switch_container.pack_end(new Gtk.Label(_("Repeat")), false, false, 0);
            
            string[] recurrency_options = {
                RecurrencyType.NO_REPEAT.to_string(),
                RecurrencyType.EVERY_X_MINUTES.to_string(),
                RecurrencyType.EVERY_DAY.to_string(),
                RecurrencyType.EVERY_WEEK.to_string(),
                RecurrencyType.EVERY_MONTH.to_string()
            };
            Gtk.ListStore list_store = new Gtk.ListStore (1, typeof(string));

            for (int i = 0; i < recurrency_options.length; i++){
                Gtk.TreeIter iter;
                list_store.append (out iter);
                list_store.set (iter, 0, recurrency_options[i]);
            }
    
            this.recurrency_combobox = new Gtk.ComboBox.with_model(list_store);

            Gtk.CellRendererText cell = new Gtk.CellRendererText();
            this.recurrency_combobox.pack_start(cell, false);

            this.recurrency_combobox.set_attributes(cell, "text", 0);            



            this.recurrency_container = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 5);
            this.recurrency_container.margin = 2;

            this.recurrency_container.pack_end(this.recurrency_combobox, false, false, 0);
            this.recurrency_container.pack_end(new Gtk.Label(_("Frequency")), false, false, 0);

            this.recurrency_container.hide();


            this.reset_fields();

            var fields_box = new Gtk.Box(Gtk.Orientation.VERTICAL, 5);
            fields_box.margin = 5;
            fields_box.pack_start(this.reminder_input, true, false, 0);
            fields_box.pack_start(this.date_picker, true, false, 0);
            fields_box.pack_start(this.time_picker, true, false, 0);
            fields_box.pack_start(recurrency_switch_container, true, false, 0);
            fields_box.pack_start(this.recurrency_container, true, false, 0);

            this.save_button = new Gtk.Button.with_label(_("Save reminder"));
            this.save_button.halign = Gtk.Align.END;
            this.save_button.get_style_context().add_class("suggested-action");
            this.save_button.activate.connect(on_save);
            this.save_button.clicked.connect(on_save);
            this.save_button.set_sensitive(false);

            pack_start(title, true, false, 0);
            pack_start(fields_box, true, false, 0);
            pack_end(this.save_button, false, false, 0);

            this.reminder_input.changed.connect(() => {
                this.touched = true;
                this.validate();
            });

            this.reminder_input.activate.connect(() => {
                this.save_button.clicked();
            });

            this.date_picker.date_changed.connect(() => {
                this.validate();
            });

            this.time_picker.time_changed.connect(() => {
                this.validate();
            });

            this.recurrency_switch.notify["active"].connect(() => {
                if (this.recurrency_switch.get_active()) {
                    this.recurrency_container.show();
                } else {
                    this.recurrency_container.hide();
                }
            });

            this.recurrency_combobox.changed.connect(() => {
                var selected_option = this.recurrency_combobox.get_active();

                //TODO: ((RecurrencyType)selected_option)
                //show or hide relevant extra UI elements depending on the option
            });
        }

        public bool validate() {
            var result = true;

            if (this.reminder_input.get_text() == null || this.reminder_input.get_text().length <= 0) {
                if (this.touched) {
                    this.reminder_input.get_style_context().add_class(Gtk.STYLE_CLASS_ERROR);
                }

                this.save_button.set_sensitive(false);
                result = false;
            } else {
                this.reminder_input.get_style_context().remove_class(Gtk.STYLE_CLASS_ERROR);
            }            

            var dateTime = this.mount_datetime(this.date_picker.date, this.time_picker.time);

            if (dateTime.compare(new GLib.DateTime.now_local()) <= 0) {
                this.date_picker.get_style_context().add_class(Gtk.STYLE_CLASS_ERROR);
                this.time_picker.get_style_context().add_class(Gtk.STYLE_CLASS_ERROR);

                this.save_button.set_sensitive(false);
                result = false;
            } else {
                this.date_picker.get_style_context().remove_class(Gtk.STYLE_CLASS_ERROR);
                this.time_picker.get_style_context().remove_class(Gtk.STYLE_CLASS_ERROR);
            }            
            
            if (result) {
                this.save_button.set_sensitive(true);
            }

            return result;
        }

        public void edit_reminder(Reminder ? existing_reminder) {
            if (existing_reminder != null) {
                this.reminder = existing_reminder;
    
                this.reminder_input.text = this.reminder.description;
                this.date_picker.date = this.reminder.time;
                this.time_picker.time = this.reminder.time;
            } else {
                this.reminder = new Reminder();
                this.reset_fields();
            }
        }

        public void reset_fields() {
            this.reminder_input.text = "";
            this.date_picker.date = new GLib.DateTime.now_local().add_minutes(15);
            this.time_picker.time = this.date_picker.date;     
            this.recurrency_combobox.set_active((int)RecurrencyType.NO_REPEAT);       
        }

        private void on_save() {
            if (this.validate()) {
                this.reminder.description = this.reminder_input.get_text();
                this.reminder.time = this.mount_datetime(this.date_picker.date, this.time_picker.time);
                this.reminder.recurrency_type = (RecurrencyType)this.recurrency_combobox.get_active();

                var result = ReminduckApp.database.upsert_reminder(this.reminder);

                if (result) {
                    reminder_created();
                } else {
                    reminder_edited();
                }
            }
        }

        private DateTime mount_datetime(DateTime date, DateTime time) {
            return new GLib.DateTime.local(
                date.get_year(),
                date.get_month(),
                date.get_day_of_month(),
                time.get_hour(),
                time.get_minute(),
                0
            );
        }
    }
}
