# project name and programming language
project('com.github.matfantinel.reminduck', 'vala', 'c')
gnome = import('gnome')

# Include the translations module
i18n = import('i18n')

# Set our translation domain
add_global_arguments('-DGETTEXT_PACKAGE="@0@"'.format (meson.project_name()), language:'c')

# Include GResource
asresources = gnome.compile_resources(
    'as-resources', join_paths('data', 'gresource.xml'),
    source_dir: 'data',
    c_name: 'as'
)

# Adds subfolders specific build system
message('Adds subfolders specific build system')

icon_sizes = ['16', '24', '32', '48', '64', '128', '256']

foreach i : icon_sizes
    install_data(
        join_paths('data/icons', i, meson.project_name() + '.svg'),
        install_dir: join_paths(get_option('datadir'), 'icons', 'hicolor', i + 'x' + i, 'apps')
    )
    install_data(
        join_paths('data/icons', i, meson.project_name() + '.svg'),
        install_dir: join_paths(get_option('datadir'), 'icons', 'hicolor', i + 'x' + i + '@2', 'apps')
    )
endforeach

# Create a new executable, list the files we want to compile, list the dependencies we need, and install
executable(
    meson.project_name(),
    'src/Application.vala',
    'src/MainWindow.vala',
    'src/Database.vala',
    'src/Objects/Reminder.vala',
    'src/Widgets/Views/ReminderEditor.vala',
    'src/Widgets/Views/RemindersView.vala',
    asresources,
    dependencies: [
        dependency('gtk+-3.0'),
        dependency('gee-0.8'),
        dependency('sqlite3'),
        dependency('granite'),
    ],
    install: true
)

#Translate and install our .desktop file
i18n.merge_file(
    input: join_paths('data', meson.project_name() + '.desktop.in'),
    output: meson.project_name() + '.desktop',
    po_dir: join_paths(meson.source_root(), 'po'),
    type: 'desktop',
    install: true,
    install_dir: join_paths(get_option('datadir'), 'applications')
)

#Translate and install our .appdata file
i18n.merge_file(
    input: join_paths('data', meson.project_name() + '.appdata.xml.in'),
    output: meson.project_name() + '.appdata.xml',
    po_dir: join_paths(meson.source_root(), 'po'),
    install: true,
    install_dir: join_paths(get_option('datadir'), 'metainfo')
)

subdir('po')

meson.add_install_script('meson/post_install.py')