'use strict';
var util = require('util');
var path = require('path');
var yeoman = require('yeoman-generator');
var chalk = require('chalk');


var GulpNgCoffeeGenerator = yeoman.generators.Base.extend({
  init: function () {
    this.pkg = require('../package.json');

    this.on('end', function () {
      if (!this.options['skip-install']) {
        this.installDependencies();
      }
    });
  },

  askFor: function () {
    var done = this.async();

    // have Yeoman greet the user
    this.log(this.yeoman);

    // replace it with a short and sweet description of your generator
    this.log(chalk.magenta('Generates an angular module using bower, gulp and coffee-script.'));

    var prompts = [{
      "name":     "moduleName",
      "message":  "Gimme a Module-Name please"
    }];

    this.prompt(prompts, function (props) {
      this.moduleName = props.moduleName;

      done();
    }.bind(this));
  },

  app: function () {
    this.mkdir('src');
    this.copy('src/_module.coffee', 'src/' + this._.slugify(this.moduleName) + '.coffee');
    this.copy('src/_module.spec.coffee','src/' + this._.slugify(this.moduleName) + '.spec.coffee');

    this.mkdir('css');
    this.copy('css/_module.css', 'css/' + this._.slugify(this.moduleName) + '.css');
  },

  projectfiles: function () {
    this.copy('_bowerrc', '.bowerrc');
    this.copy('_bower.json', 'bower.json');
    this.copy('_gulpfile.coffee', 'gulpfile.coffee');
    this.copy('_package.json', 'package.json');
    this.copy('_karma-unit.coffee', 'karma-unit.coffee');
  }
});

module.exports = GulpNgCoffeeGenerator;