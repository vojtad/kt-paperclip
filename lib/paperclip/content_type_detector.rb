module Paperclip
  class ContentTypeDetector
    # The content-type detection strategy is as follows:
    #
    # 1. Blank/Empty files: If there's no filepath or the file is empty,
    #    provide a sensible default (application/octet-stream or inode/x-empty)
    #
    # 2. Return content type found by file content or extensions by Marcel.
    #
    # 5. Raw `file` command: Just use the output of the `file` command raw, or
    #    a sensible default.

    EMPTY_TYPE = "inode/x-empty"
    SENSIBLE_DEFAULT = "application/octet-stream"

    def initialize(filepath)
      @filepath = filepath
    end

    # Returns a String describing the file's content type
    def detect
      if blank_name?
        SENSIBLE_DEFAULT
      elsif empty_file?
        EMPTY_TYPE
      else
        type_from_file_contents || SENSIBLE_DEFAULT
      end.to_s
    end

    private

    def blank_name?
      @filepath.nil? || @filepath.empty?
    end

    def empty_file?
      File.exist?(@filepath) && File.size(@filepath) == 0
    end

    alias :empty? :empty_file?

    def type_from_file_contents
      type_from_marcel || type_from_file_command
    rescue Errno::ENOENT => e
      Paperclip.log("Error while determining content type: #{e}")
      SENSIBLE_DEFAULT
    end

    def type_from_marcel
      return @type_from_marcel if defined? @type_from_marcel

      @type_from_marcel = Marcel::MimeType.for Pathname.new(@filepath),
                                               name: @filepath
      # Marcel::MineType returns 'application/octet-stream' if it can't find
      # a valid type.
      @type_from_marcel = nil if @type_from_marcel == SENSIBLE_DEFAULT
      @type_from_marcel
    end

    def type_from_file_command
      @type_from_file_command ||=
        FileCommandContentTypeDetector.new(@filepath).detect
    end
  end
end
