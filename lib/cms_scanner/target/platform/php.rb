module CMSScanner
  class Target < WebSite
    module Platform
      # Some PHP specific implementation
      module PHP
        DEBUG_LOG_PATTERN = /\[[^\]]+\] PHP (?:Warning|Error|Notice):/.freeze
        FPD_PATTERN       = /Fatal error:.+? in (.+?) on/.freeze
        ERROR_LOG_PATTERN = /PHP Fatal error/i.freeze

        # @param [ String ] path
        # @param [ Regexp ] pattern
        # @param [ Hash ] params The request params
        #
        # @return [ Boolean ]
        def log_file?(path, pattern, params = {})
          # Only the first 700 bytes of the file are retrieved to avoid getting enture log file
          # which can be huge (~ 2Go)
          res = NS::Browser.get(url(path), params.merge(headers: { 'range' => 'bytes=0-700' }))

          res.body =~ pattern ? true : false
        end

        # @param [ String ] path
        # @param [ Hash ] params The request params
        #
        # @return [ Boolean ] true if  url(path) is a debug log, false otherwise
        def debug_log?(path, params = {})
          log_file?(path, DEBUG_LOG_PATTERN, params)
        end

        # @param [ String ] path
        # @param [ Hash ] params The request params
        #
        # @return [ Boolean ] Wether or not url(path) is an error log file
        def error_log?(path, params = {})
          log_file?(path, ERROR_LOG_PATTERN, params)
        end

        # @param [ String ] path
        # @param [ Hash ] params The request params
        #
        # @return [ Boolean ] true if url(path) contains a FPD, false otherwise
        def full_path_disclosure?(path = nil, params = {})
          !full_path_disclosure_entries(path, params).empty?
        end

        # @param [ String ] path
        # @param [ Hash ] params The request params
        #
        # @return [ Array<String> ] The FPD found, or an empty array if none
        def full_path_disclosure_entries(path = nil, params = {})
          res = NS::Browser.get(url(path), params)

          res.body.scan(FPD_PATTERN).flatten
        end
      end
    end
  end
end
