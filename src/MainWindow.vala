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

namespace Reminduck {
    public class MainWindow : Gtk.ApplicationWindow {
        Gtk.Stack stack;
        Gtk.HeaderBar headerbar;
        Gtk.Button back_button;

        private GLib.Settings settings;

        Granite.Widgets.Welcome welcome_widget = null;
        int? view_reminders_action_reference = null;

        Widgets.Views.ReminderEditor reminder_editor;
        Widgets.Views.RemindersView reminders_view;

        public MainWindow() {
            settings = new GLib.Settings("com.github.matfantinel.reminduck.state");

            move(settings.get_int("window-x"), settings.get_int("window-y"));
            resize(settings.get_int("window-width"), settings.get_int("window-height"));

            build_ui();
        }

        private void build_ui() {
            stack = new Gtk.Stack();
            stack.set_transition_duration(500);

            this.build_headerbar();
            
            this.build_welcome();
            
            var image = new Gtk.Image();
            image.set_from_icon_name("com.github.matfantinel.reminduck", Gtk.IconSize.DIALOG);
            image.set_margin_top(30);

            var fields_box = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
            fields_box.get_style_context().add_class("reminduck-welcome-box");
            fields_box.pack_start(image, false, false, 0);
            fields_box.pack_start(this.welcome_widget, true, true, 0);

            stack.add_named(fields_box, "welcome");

            this.build_reminder_editor();
            this.build_reminders_view();

            add(stack);            

            this.show_welcome_view(Gtk.StackTransitionType.NONE);

            delete_event.connect(e => {
                return before_destroy();
            });
        }        

        private void build_headerbar() {
            this.headerbar = new Gtk.HeaderBar();
            this.headerbar.show_close_button = true;
            this.headerbar.title = "Reminduck";
            this.headerbar.get_style_context().add_class("default-decoration");
            this.headerbar.get_style_context().add_class("reminduck-headerbar");
            set_titlebar(this.headerbar);

            this.back_button = new Gtk.Button.with_label(_("Back"));
            this.back_button.get_style_context().add_class("back-button");
            this.back_button.valign = Gtk.Align.CENTER;
            this.headerbar.pack_start(this.back_button);
            
            this.back_button.clicked.connect(() => {
                this.show_welcome_view();                
            });            

            var mode_switch = new Granite.ModeSwitch.from_icon_name ("display-brightness-symbolic", "weather-clear-night-symbolic");
            mode_switch.primary_icon_tooltip_text = _("Light mode");
            mode_switch.secondary_icon_tooltip_text = _("Dark mode");
            mode_switch.valign = Gtk.Align.CENTER;

            this.headerbar.pack_end(mode_switch);

            var context = get_style_context ();
            mode_switch.notify["active"].connect (() => {
                if (mode_switch.active) {
                    context.add_class ("dark");
                } else {
                    context.remove_class ("dark");
                }
            });

            this.settings.bind ("use-dark-theme", mode_switch, "active", GLib.SettingsBindFlags.DEFAULT);
            var gtk_settings = Gtk.Settings.get_default ();
            mode_switch.bind_property ("active", gtk_settings, "gtk_application_prefer_dark_theme");
        }

        private void build_welcome() {
            this.welcome_widget = new Granite.Widgets.Welcome(
                _("QUACK! I'm Reminduck"),
                _("The duck that reminds you")
            );

            this.welcome_widget.activated.connect((index) => {
                switch(index) {
                    case 0:
                        show_reminder_editor();
                        break;
                    case 1:
                        show_reminders_view(Gtk.StackTransitionType.SLIDE_LEFT);
                        break;
                }
            });

            this.welcome_widget.append("document-new", _("New Reminder"), _("Create a new reminder for a set date and time"));
            if (ReminduckApp.reminders.size > 0) {
                this.view_reminders_action_reference = this.welcome_widget.append("document-open", _("View Reminders"), _("See reminders you've created"));
            }
        }

        private void update_view_reminders_welcome_action() {
            if (ReminduckApp.reminders.size > 0) {
                if (this.view_reminders_action_reference == null) {
                    this.view_reminders_action_reference = this.welcome_widget.append("document-open", _("View Reminders"), _("See reminders you've created"));
                    this.welcome_widget.show_all();
                }
            } else {
                if (this.view_reminders_action_reference != null) {
                    this.welcome_widget.remove_item(this.view_reminders_action_reference);
                }
                this.view_reminders_action_reference = null;
            }
        }

        private void build_reminder_editor() {
            this.reminder_editor = new Widgets.Views.ReminderEditor();

            this.reminder_editor.reminder_created.connect((new_reminder) => {
                ReminduckApp.reload_reminders();                
                show_reminders_view();
            });

            this.reminder_editor.reminder_edited.connect((edited_file) => {
                ReminduckApp.reload_reminders();
                show_reminders_view();
            });

            stack.add_named(this.reminder_editor, "reminder_editor");
        }

        private void build_reminders_view() {
            this.reminders_view = new Widgets.Views.RemindersView();

            this.reminders_view.add_request.connect(() => {
                show_reminder_editor();
            });

            this.reminders_view.edit_request.connect((reminder) => {
                show_reminder_editor(reminder);
            });

            this.reminders_view.reminder_deleted.connect(() => {
                ReminduckApp.reload_reminders();
                if (ReminduckApp.reminders.size == 0) {
                    show_welcome_view();
                } else {
                    this.reminders_view.build_reminders_list();
                }
            });

            stack.add_named(this.reminders_view, "reminders_view");
        }

        private void show_reminder_editor(Reminder? reminder = null) {
            stack.set_transition_type(Gtk.StackTransitionType.SLIDE_LEFT);
            stack.set_visible_child_name("reminder_editor");
            this.back_button.show_all();
            this.reminder_editor.edit_reminder(reminder);
        }

        private void show_reminders_view(Gtk.StackTransitionType slide = Gtk.StackTransitionType.SLIDE_RIGHT) {
            stack.set_transition_type(slide);
            stack.set_visible_child_name("reminders_view");
            this.reminders_view.build_reminders_list();
            this.back_button.show_all();
            this.reminder_editor.reset_fields();
        }

        public void show_welcome_view(Gtk.StackTransitionType slide = Gtk.StackTransitionType.SLIDE_RIGHT) {
            this.update_view_reminders_welcome_action();
            stack.set_transition_type(slide);
            stack.set_visible_child_name("welcome");
            this.back_button.hide();
            this.reminder_editor.reset_fields();
        }

        private bool before_destroy() {
            int x, y, width, height;
    
            get_position(out x, out y);
            get_size(out width, out height);
    
            this.settings.set_int("window-x", x);
            this.settings.set_int("window-y", y);
            this.settings.set_int("window-width", width);
            this.settings.set_int("window-height", height);
    
            hide();
            return true;
        }
    }
}
