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

//  Originally from elementary-tweaks
namespace Reminduck {

    /**
     * Settings for Gtk; thanks gnome-tweak-tool for the help!
     */
    public class GtkSettings {
        private GLib.KeyFile keyfile;
        private string path;
        private static GtkSettings? instance = null;

        /**
         * GTK should prefer the dark theme or not
         */
        public bool prefer_dark_theme {
            get { return (get_integer ("gtk-application-prefer-dark-theme") == 1); }
        }

        /**
         * Creates a new GTKSettings
         */
        public GtkSettings () {
            keyfile = new GLib.KeyFile ();

            try {
                path = GLib.Environment.get_user_config_dir() + "/gtk-3.0/settings.ini";
                keyfile.load_from_file (path, 0);
            }
            catch (Error e) {
                warning ("Error loading GTK+ Keyfile settings.ini: " + e.message);
            }
        }

        public static GtkSettings get_default () {
            if (instance == null)
                instance = new GtkSettings ();

            return instance;
        }

        /**
         * Gets an integer from the keyfile at Settings group
         */
        private int get_integer (string key) {
            int key_int = 0;

            try {
                key_int = keyfile.get_integer ("Settings", key);
            }
            catch (Error e) {
                warning ("Error getting GTK+ int setting: " + e.message);
            }

            return key_int;
        }        
    }
}