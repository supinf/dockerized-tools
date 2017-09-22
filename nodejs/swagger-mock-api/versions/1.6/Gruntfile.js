'use strict';

var path = require('path');
var mockApi = require('swagger-mock-api');

module.exports = function (grunt) {

  grunt.initConfig({
    connect: {
      server: {
        options: {
          keepalive: true,
          middleware: [
            function (req, res, next) {
                res.setHeader('Access-Control-Allow-Origin', '*');
                res.setHeader('Access-Control-Allow-Methods', 'GET,POST,PUT,DELETE');
                res.setHeader('Access-Control-Allow-Headers', 'Origin, Content-Type, Accept, Authorization');
                res.setHeader("Access-Control-Max-Age", "86400");
                if (req.method == 'OPTIONS') {
                    res.end('ok!');
                } else {
                    next();
                }
            },
            mockApi({
                swaggerFile: (process.env.SWAGGER_YAML_PATH || '/api/swagger.yaml'),
                watch: true
            })
          ]
        }
      }
    }
  });

  grunt.loadNpmTasks('grunt-contrib-connect');
  grunt.registerTask('default', ['connect']);
};
