/**
 * Booting class (main)
 * @author Axel Anceau (Peekmo)
 */
class Boot
{
    static function main() : Void
    {
        var args : Array<String> = Sys.args();

        for (arg in args.iterator()) {
            if ('build' == arg) {
                var action = new Build();
            }
        }
    }
}