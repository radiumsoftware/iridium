require 'fileutils'

module Iridium
  module Pipeline
    extend ActiveSupport::Concern

    module ClassMethods
      def compile
        instance.compile
      end
    end

    attr_accessor :app_path, :site_path, :tmp_path, :assetfile_path

    def initialize
      @app_path = root.join 'app'
      @site_path = root.join 'site'
      @tmp_path = root.join 'tmp'
      @assetfile_path = root.join 'Assetfile'
    end

    def compile
      pipeline.clean
      pipeline.invoke
    end
  end
end
