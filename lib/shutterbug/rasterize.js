/*global phantom */

var page = require('webpage').create(),
    system = require('system'),
    address, output, quality, size;

if (system.args.length < 3 || system.args.length > 5) {
    console.log('Usage: rasterize.js URL filename quality(0-100)');
    phantom.exit(1);
} else {
    address = system.args[1];
    output = system.args[2];
    page.viewportSize = { width: 1000, height: 700 };
    if (system.args.length > 3) {
        size = system.args[3].split('*');
        page.viewportSize = { width: size[0], height: size[1] };
        quality = system.args[4];
    }

    page.open(address, function (status) {
        if (status !== 'success') {
            console.log('Unable to load the address!');
            phantom.exit();
        } else {
            window.setTimeout(function () {
                page.render(output, {quality: quality});
                phantom.exit();
            }, 200);
        }
    });
}
