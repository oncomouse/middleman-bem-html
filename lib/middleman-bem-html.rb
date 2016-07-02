require 'active_support/core_ext/object/try'
require 'memoist'
require 'middleman-core/contracts'
require 'css_dead_class'
require 'bem_html'

class ::Middleman::Extension::BemHtml < ::Middleman::Extension
	option :ignore, [], 'Patterns to avoid minifying'
	option :inline_content_types, %w(text/html text/php), 'Content types of resources that contain bem commands'

	def initialize(app, options_hash={}, &block)
		super
	end
	
	def ready
		# Setup Rack middleware to minify CSS
		app.use Rack, compressor: options[:compressor],
									ignore: Array(options[:ignore]) + [/\.min\./],
									inline_content_types: options[:inline_content_types]
	end
	
	def after_build
		# This will work if you are building your CSS files in Middleman. If you are using an external_pipeline,
		# this after_build method will trigger before the external_pipeline. As such, you need to use PostCSS
		# and http://github.com/oncomouse/postcss-deadclass to remove all the cruft.

		# Set config[:internal_css] to false if you are using an external_pipeline and postcss-deadclass
		runInternalDeCrufter = app.config.internal_css || true
		if runInternalDeCrufter
			classesToKeep = app.config.classes_to_keep || []
			cssFiles = Dir.glob("#{app.config.build_dir}/#{app.config.css_dir}/**/*.css")
			htmlFiles = Dir.glob("#{app.config.build_dir}/**/*.html")
			
			css_deadfiles = CSSDeadClass.new({
				html_files: htmlFiles,
				css_files: cssFiles,
				classes_to_keep: classesToKeep
			})
			css_deadfiles.parse
		end
	end

	class Rack
		extend Memoist
		include Contracts

		# Init
		# @param [Class] app
		# @param [Hash] options
		Contract RespondTo[:call], {
			ignore: ArrayOf[PATH_MATCHER]
		} => Any
		def initialize(app, options={})
			@app = app
			@ignore = options.fetch(:ignore)
			@inline_content_types = options[:inline_content_types]
		end

		# Rack interface
		# @param [Rack::Environmemt] env
		# @return [Array]
		def call(env)
			status, headers, response = @app.call(env)

			content_type = headers['Content-Type'].try(:slice, /^[^;]*/)
			path = env['PATH_INFO']

			minified = if minifiable_inline?(content_type)
				minify_inline(::Middleman::Util.extract_response_text(response))
			end

			if minified
				headers['Content-Length'] = ::Rack::Utils.bytesize(minified).to_s
				response = [minified]
			end

			[status, headers, response]
		end

		private

		# Whether the path should be ignored
		# @param [String] path
		# @return [Boolean]
		def ignore?(path)
			@ignore.any? { |ignore| ::Middleman::Util.path_match(ignore, path) }
		end
		memoize :ignore?
		
		# Whether this type of content contains inline content that can be minified
		# @param [String, nil] content_type
		# @return [Boolean]
		def minifiable_inline?(content_type)
			@inline_content_types.include?(content_type)
		end
		memoize :minifiable_inline?

		# Detect and minify inline content
		# @param [String] content
		# @return [String]
		def minify_inline(content)
			BemHtml.parse(content)
		end
		memoize :minify_inline
	end
end


Middleman::Extensions.register :bem_html do
  #require "bem_html/extension"
  ::Middleman::Extension::BemHtml
end