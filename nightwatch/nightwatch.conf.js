const chromedriver = require('chromedriver');
const geckodriver = require('geckodriver');

module.exports = {
    test_settings: {
        default: {
            webdriver: {
                start_process: true,
                server_path: chromedriver.path,
                port: 4444,
                cli_args: ['--port=4444']
            },
            desiredCapabilities: {
                browserName: 'chrome',
                javascriptEnabled: true,
                acceptSslCerts: true,
                chromeOptions: {
                    args: ['disable-gpu']
                }
            },
            screenshots: {
                enabled: true,
                path: 'screenshots'
            }
        },

        headless: {
            desiredCapabilities: {
                browserName: 'chrome',
                chromeOptions: {
                    args: ['headless', 'disable-gpu']
                }
            }
        },
    }
};
