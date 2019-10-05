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

namespace Reminduck {
    public class MainWindow : Gtk.ApplicationWindow {
        Gtk.Stack stack;
        Gtk.HeaderBar headerbar;
        Gtk.Button back_button;

        Granite.Widgets.Welcome welcome_widget = null;
        int? view_reminders_action_reference = null;

        Widgets.Views.ReminderEditor reminder_editor;
        Widgets.Views.RemindersView reminders_view;

        public MainWindow() {
            buildUI();
        }

        private void buildUI() {
            stack = new Gtk.Stack();
            stack.set_transition_duration (500);

            this.set_default_size (400, 550);

            build_headerbar();
            build_welcome ();
            stack.add_named (this.welcome_widget, "welcome");
            build_reminder_editor ();
            build_reminders_view ();

            add (stack);            

            show_all();            

            show_welcome_view (Gtk.StackTransitionType.NONE);
            this.present();
        }        

        private void build_headerbar() {
            headerbar = new Gtk.HeaderBar();
            headerbar.show_close_button = true;
            headerbar.title = "Reminduck";
            headerbar.get_style_context().add_class ("default-decoration");
            headerbar.get_style_context ().add_class ("reminduck-headerbar");
            set_titlebar (headerbar);

            back_button = new Gtk.Button.with_label (_("Back"));
            back_button.get_style_context().add_class ("back-button");
            back_button.valign = Gtk.Align.CENTER;
            headerbar.pack_start (back_button);
            
            back_button.clicked.connect (() => {
                show_welcome_view();                
            });
        }

        private void build_welcome () {
            this.welcome_widget = new Granite.Widgets.Welcome (
                _("QUACK! I'm Reminduck"),
                _("The duck that reminds you")
            );

            this.welcome_widget.activated.connect ((index) => {
                switch (index) {
                    case 0:
                        show_reminder_editor();
                        break;
                    case 1:
                        show_reminders_view(Gtk.StackTransitionType.SLIDE_LEFT);
                        break;
                }
            });

            this.welcome_widget.append ("document-new", _("New Reminder"), _("Create a new reminder for a set date and time"));
            if (ReminduckApp.reminders.size > 0) {
                this.view_reminders_action_reference = this.welcome_widget.append ("emblem-documents", _("View Reminders"), _("See reminders you've created"));
            }
                
            this.welcome_widget.show_all ();
        }

        private void update_view_reminders_welcome_action () {
            if (ReminduckApp.reminders.size > 0) {
                if (this.view_reminders_action_reference == null) {
                    this.view_reminders_action_reference = this.welcome_widget.append ("emblem-documents", _("View Reminders"), _("See reminders you've created"));
                    this.welcome_widget.show_all ();
                }
            } else {
                if (this.view_reminders_action_reference != null) {
                    this.welcome_widget.remove_item (this.view_reminders_action_reference);
                }
                this.view_reminders_action_reference = null;
            }
        }

        private void build_reminder_editor () {
            reminder_editor = new Widgets.Views.ReminderEditor();

            reminder_editor.reminder_created.connect ((new_reminder) => {
                ReminduckApp.reload_reminders ();                
                show_reminders_view();
            });

            reminder_editor.reminder_edited.connect ((edited_file) => {
                ReminduckApp.reload_reminders ();
                show_reminders_view();
            });

            reminder_editor.show_notification.connect((title, body) => {
                var notification = new Notification (title);
                notification.set_body (body);
                this.get_application().send_notification ("notify.app", notification);
            });

            stack.add_named (reminder_editor, "reminder_editor");
        }

        private void build_reminders_view () {
            reminders_view = new Widgets.Views.RemindersView();

            reminders_view.add_request.connect (() => {
                show_reminder_editor();
            });

            reminders_view.edit_request.connect ((reminder) => {
                show_reminder_editor();;
            });

            reminders_view.reminder_deleted.connect (() => {
                ReminduckApp.reload_reminders ();
                if (ReminduckApp.reminders.size == 0) {
                    show_welcome_view ();
                } else {
                    reminders_view.build_reminders_list();
                }
            });

            stack.add_named (reminders_view, "reminders_view");
        }

        private void show_reminder_editor (Reminder? reminder = null) {
            stack.set_transition_type (Gtk.StackTransitionType.SLIDE_LEFT);
            stack.set_visible_child_name("reminder_editor");
            back_button.show_all();
            reminder_editor.edit_reminder (reminder);
        }

        private void show_reminders_view (Gtk.StackTransitionType slide = Gtk.StackTransitionType.SLIDE_RIGHT) {
            stack.set_transition_type (slide);
            stack.set_visible_child_name ("reminders_view");
            reminders_view.build_reminders_list();
            back_button.show_all();
            reminder_editor.reset_fields();
        }

        private void show_welcome_view (Gtk.StackTransitionType slide = Gtk.StackTransitionType.SLIDE_RIGHT) {
            update_view_reminders_welcome_action ();
            stack.set_transition_type (slide);
            stack.set_visible_child_name ("welcome");
            back_button.hide();
            reminder_editor.reset_fields();
        }        
    }
}
