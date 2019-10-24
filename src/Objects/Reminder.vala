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
    public class Reminder : GLib.Object {
        public string rowid { get; set; }
        public string description { get; set; }
        public GLib.DateTime time { get; set; }
        public RecurrencyType recurrency_type { get; set; default = RecurrencyType.NONE; }
        public int recurrency_interval { get; set; }

        public Reminder() {
            
        }
    }

    public enum RecurrencyType {
        EVERY_X_MINUTES,
        EVERY_DAY,
        EVERY_WEEK,
        EVERY_MONTH,
        NONE;

        public string to_friendly_string(int? interval = null) {
            switch (this) {   
                case NONE:
                    return _("Don't Repeat");
                    
                case EVERY_X_MINUTES:
                    if (interval == null || interval == 0) {
                        return _("Every X minutes");
                    } else {
                        return GLib.ngettext ("Every minute", "Every %d minutes", interval).printf (interval);
                    }
    
                case EVERY_DAY:
                    return _("Every day");
    
                case EVERY_WEEK:
                    return _("Every week");

                case EVERY_MONTH:
                    return _("Every month");
    
                default:
                    assert_not_reached();
            }
        }
    }
}
