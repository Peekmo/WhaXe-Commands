import wx.tools.JsonDynamic;
import wx.tools.JsonParser;
import wx.exceptions.FileNotFoundException;

/**
 * On building WhaXe project
 * @author Axel Anceau (Peekmo)
 */
class Build
{
    /**
     * Constructor
     */
    public function new()
    {
        trace('Building dependencies');
        this.buildDependencies();
    }

    /**
     * Creates imports of services / controllers
     */
    private function buildDependencies() : Void
    {
        var pathImportClass : String = 'application/Imports.hx';

        if (sys.FileSystem.exists(pathImportClass)) {
            sys.FileSystem.deleteFile(pathImportClass);
        }


        var file : sys.io.FileOutput = sys.io.File.write(pathImportClass, false);
        this.buildFromWhaXe(file);

        var stringClass : String = 'class Imports {}';
        file.writeString(stringClass);
        file.flush();
        file.close();
    }

    /**
     * Write the full configuration
     * @param  file: sys.io.FileOutput File to write
     */
    private function buildFromWhaXe(file: sys.io.FileOutput) : Void
    {
        try {
            var content : String = sys.io.File.getContent('application/config/bundles.json');
            var libs : JsonDynamic = JsonParser.decode(content);

            // Get config.json from each internal bundles
            for (i in libs['internals'].iterator()) {
                var folder : String = Std.string(libs['internals'][i]).split('.').join('/');
                
                var servicesFile : String = sys.io.File.getContent('src/' + folder + '/config/services.json');
                var services : JsonDynamic = JsonParser.decode(servicesFile);
                this.writeServices(file, services['services']);

                var routingFile : String = sys.io.File.getContent('src/' + folder + '/config/routing.json');
                var routes : JsonDynamic = JsonParser.decode(routingFile);
                this.writeControllers(file, routes['routes']);
            }

            // Get config.json from each external bundles
            for (i in libs['externals'].iterator()) {
                var folder : String = Std.string(libs['externals'][i]).split('.').join('/');

                var servicesFile : String = sys.io.File.getContent('lib/' + folder + '/config/services.json');
                var services : JsonDynamic = JsonParser.decode(servicesFile);
                this.writeServices(file, services['services']);

                var routingFile : String = sys.io.File.getContent('lib/' + folder + '/config/routing.json');
                var routes : JsonDynamic = JsonParser.decode(routingFile);
                this.writeControllers(file, routes['routes']);
            }
        } catch (ex: String) {
            throw new FileNotFoundException('No bundles configuration found (' + ex.split(':')[0] +')');
        }
    }

    /**
     * Write service's imports
     * @param  file:     sys.io.FileOutput File to write
     * @param  services: JsonDynamic       Services to write
     */
    private function writeServices(file: sys.io.FileOutput, services: JsonDynamic) : Void
    {
        if (null == services) {
            return;
        }

        for (i in services.iterator()) {
            file.writeString('import ' + Std.string(services[i]['class']) + ';\n');
        }
    }

    /**
     * Write controller's imports
     * @param  file:   sys.io.FileOutput Target file
     * @param  routes: JsonDynamic       Routes to write
     */
    private function writeControllers(file: sys.io.FileOutput, routes: JsonDynamic) : Void
    {
        if (null == routes) {
            return;
        }

        for (i in routes.iterator()) {
            file.writeString('import ' + Std.string(routes[i]['controller']) + ';\n');
        }
    }
}