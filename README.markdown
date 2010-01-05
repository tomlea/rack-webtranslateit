![rack-webtranslateit](http://s3.amazonaws.com:80/edouard.baconfile.com/rack-webtranslateit.png)

# Usage:

* Sign up for a webtranslateit.com premium account.
* Create a config/translation.yml file:

        # The Project API Token from Web Translate It
        api_key: ffffffffffffffffffffffffffffffffffffffff
        
        # The locales not to sync with Web Translate It.
        # Pass an array of string, or an array of symbols, a string or a symbol.
        # eg. [:en, :fr] or just 'en'
        ignore_locales: :en
        
        # A list of files to translate
        # You can name your language files as you want, as long as the locale name match the
        # locale name you set in Web Translate It, and that the different language files names are
        # differenciated by their locale name.
        # For example, if you set to translate a project in en_US in WTI, you should use the locale en_US in your app
        #
        # wti_id is the file id from Web Translate It.
        files:
          1234: config/locales/[locale].yml
        
        # Optional password to access the web interface
        password: password

* Add the middleware:

        config.gem 'rack-webtranslateit', :lib => 'rack/webtranslateit'
        config.middleware.use "Rack::Webtranslateit", "/translations/"

* Go to http://yourapp/translations.
* Click update translations.
