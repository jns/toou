require 'barby'
require 'barby/barcode/code_128'
require 'barby/outputter/html_outputter'

module WelcomeHelper

    def barcode_for(pass)
        Barby::Code128B.new(@pass.barcode_payload).to_html.html_safe
    end
end
