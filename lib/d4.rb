require 'ffi'

module D4
  class Error < StandardError; end

  class << self
    def lib_path
      name = "libd4binding.#{::FFI::Platform::LIBSUFFIX}"
      path = ENV['D4_LIB_PATH'] || File.expand_path("../vendor/#{name}", __dir__)
      raise Error, "libd4binding not found at #{path}" unless File.exist?(path)

      path
    end
  end
end

require_relative 'd4/ffi'
