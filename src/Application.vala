int main (string[] args) {
    if (args.length != 3) {
        stdout.printf ("Usage: %s [input file] [output file]\n", args[0]);
        return 1;
    }

    Av.Format.register_all ();

    int ret = 0;
    unowned Av.Format.Context? input_context = null;

    if ((ret = Av.Format.Context.open_input (out input_context, args[1], null, null)) < 0) {
        stderr.printf ("Could not open input file: %s\n", args[1]);
         Av.Format.Context.close_input (ref input_context);
         return 1;
    }

    if ((ret = input_context.find_stream_info (null)) < 0) {
        stderr.printf ("Failed to retrieve input stream information\n");
        Av.Format.Context.close_input (ref input_context);
        return 1;
    }

    input_context.dump_format (0, args[1], false);

    Av.Format.Context? output_context = null;
    if ((ret = Av.Format.Context.alloc_output_context2 (out output_context, null, null, args[2])) < 0) {
        stderr.printf ("Could not create output context\n");
        Av.Format.Context.close_input (ref input_context);
        return 1;
    }

    int stream_index = 0;
    int[] stream_mappings = new int[input_context.streams.length];

    for (int i = 0; i < input_context.streams.length; i++) {
        unowned Av.Format.Stream out_stream;

        unowned Av.Format.Stream input_stream = input_context.streams[i];
        unowned Av.Codec.Parameters input_codec_parameters = input_stream.codecpar;

        if (input_codec_parameters.codec_type != Av.Util.MediaType.VIDEO &&
            input_codec_parameters.codec_type != Av.Util.MediaType.AUDIO &&
            input_codec_parameters.codec_type != Av.Util.MediaType.SUBTITLE) {
                stream_mappings[i] = -1;
                continue;
        }

        stream_mappings[i] = stream_index++;

        out_stream = output_context.new_stream (null);
        if (out_stream == null) {
            stderr.printf ("Failed allocating output stream\n");
            Av.Format.Context.close_input (ref input_context);
            return 1;
        }

        ret = out_stream.codecpar.copy_from (input_stream.codecpar);
        if (ret < 0) {
            stderr.printf ("Failed to copy codec parameters\n");
            Av.Format.Context.close_input (ref input_context);
            return 1;
        }

        out_stream.codecpar.codec_tag = 0;
    }

    output_context.dump_format (0, args[2], true);

    unowned Av.Format.OutputFormat output_format = output_context.oformat;
    if (!(Av.Format.Flag.NOFILE in output_format.flags)) {
        ret = Av.Format.AVIOContext.open (out output_context.pb, args[2], Av.Format.AVIOContext.Flag.WRITE);
        if (ret < 0) {
            stderr.printf ("Could not open output file\n");
            Av.Format.Context.close_input (ref input_context);
            Av.Format.AVIOContext.closep (ref output_context.pb);
            return 1;
        }
    }

    ret = output_context.write_header (null);
    if (ret < 0) {
        stderr.printf ("Error occured while opening output file\n");
        Av.Format.Context.close_input (ref input_context);
        if (output_context != null && !(Av.Format.Flag.NOFILE in output_format.flags)) {
            Av.Format.AVIOContext.closep (ref output_context.pb);
        }

        return 1;
    }

    while (true) {
        message ("iter");
        Av.Codec.Packet? packet = null;
        unowned Av.Format.Stream in_stream, out_stream;
        ret = input_context.read_frame (ref packet);
        if (ret < 0) {
            break;
        }
    }

    Av.Format.Context.close_input (ref input_context);
    if (output_context != null && !(Av.Format.Flag.NOFILE in output_format.flags)) {
        Av.Format.AVIOContext.closep (ref output_context.pb);
    }

    return 0;
}
