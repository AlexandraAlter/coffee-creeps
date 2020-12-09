module.exports = function(grunt) {

    var config = require('./.screeps.json');
    var branch = grunt.option('branch') || config.branch;
    var email = grunt.option('email') || config.email;
    var password = grunt.option('password') || config.password;
    var token = grunt.option('token') || config.token;
    var ptr = grunt.option('ptr') ? true : config.ptr;
    var server = config.server ? config.server : undefined;

    grunt.loadNpmTasks('grunt-screeps');

    grunt.initConfig({
        screeps: {
            options: {
                server: server,
                email: email,
                password: password,
                token: token,
                branch: branch,
                ptr: ptr
            },
            dist: {
                src: ['dist/*.js', 'dist/*.wasm']
            }
        }
    });
}
