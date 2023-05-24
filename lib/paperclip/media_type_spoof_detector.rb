module Paperclip
  class MediaTypeSpoofDetector
    def self.using(file, name, content_type)
      new(file, name, content_type)
    end

    def initialize(file, name, content_type)
      @file = file
      @name = name
      @content_type = content_type || ""
    end

    def spoofed?
      if has_name? && media_type_mismatch? && mapping_override_mismatch?
        Paperclip.log("Content Type Spoof: filename #{File.basename(@name)}, supplied content type #{supplied_content_type}, detected content type #{detected_content_type}, mapped content type #{mapped_content_type}. See documentation to allow this combination.")
        true
      else
        false
      end
    end

    private

    def has_name?
      @name.present?
    end

    def has_extension?
      File.extname(@name).present?
    end

    def media_type_mismatch?
      supplied_media_type.present? && supplied_media_type != detected_media_type
    end

    def mapping_override_mismatch?
      mapped_content_type.present? && mapped_content_type != detected_content_type
    end

    def supplied_content_type
      @content_type
    end

    def supplied_media_type
      @content_type.split("/").first
    end

    def detected_content_type
      @detected_content_type ||= Paperclip::ContentTypeDetector.new(@file.path).detect
    end

    def detected_media_type
      detected_content_type.split("/").first
    end

    def mapped_content_type
      Paperclip.options[:content_type_mappings][filename_extension]
    end

    def filename_extension
      File.extname(@name.to_s.downcase).sub(/^\./, "").to_sym
    end
  end
end
