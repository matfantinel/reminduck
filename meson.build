project('com.github.matfantinel.reminduck', 'vala', 'c', version: '1.4.0')

gnome = import('gnome')
i18n = import('i18n')

add_project_arguments(
    '-DGETTEXT_PACKAGE="@0@"'.format(meson.project_name()),
    language: 'c'
)

asresources = gnome.compile_resources(
    'as-resources',
    join_paths('data', meson.project_name()) + '.gresource.xml',
    source_dir: 'data',
    c_name: 'as'
)

subdir('src')

executable(
    meson.project_name(),
    sources,
    asresources,
    dependencies: [
        dependency('gtk+-3.0'),
        dependency('gee-0.8'),
        dependency('sqlite3'),
        dependency('granite')
    ],
    install: true
)

subdir('data')
subdir('po')

meson.add_install_script('meson/post_install.py')
