project ('com.github.cassidyjames.anamorph', 'vala', 'c')

gnome = import ('gnome')
i18n = import ('i18n')

add_global_arguments ('-DGETTEXT_PACKAGE="' + meson.project_name () + '"', language:'c')

vapi_dir = join_paths(meson.current_source_dir(), 'vapi')
add_project_arguments(['--vapidir', vapi_dir], language: 'vala')

anamorph_files = files (
    'src/Application.vala'
)

executable (
    meson.project_name (),
    anamorph_files,
    dependencies: [
        dependency ('glib-2.0'),
        dependency ('libavformat'),
        dependency ('libavutil'),
        dependency ('libavcodec'),
        meson.get_compiler('vala').find_library('posix'),
    ],
    install: true
)

