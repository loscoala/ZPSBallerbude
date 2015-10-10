<?php
/*
 * * * * * * * * * * * * * * * * * * * * * * * * * *
 * (c) 2009 KillerSpieler                          *
 * http://steamcommunity.com/groups/ZPSBallerbude  *
 * * * * * * * * * * * * * * * * * * * * * * * * * *
 * 
 * =============================================================================
 *
 * This program is free software; you can redistribute it and/or modify it under
 * the terms of the GNU General Public License, version 3.0, as published by the
 * Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
 * details.
 *
 * You should have received a copy of the GNU General Public License along with
 * this program.  If not, see <http://www.gnu.org/licenses/>.
 */
class CommandHTMLWriter
{
    private $commands;
    private $document;

    public function __construct($commandsArray = null)
    {
        if ($commandsArray !== null)
        {
            $this->commands = $commandsArray;
        }
    }
    
    private function insertCommands($node)
    {
        foreach ($this->commands as $command => $description)
        {
            $listElement = $node->appendChild(new DOMElement("li"));
            $listElement->appendChild(new DOMText($command . " - " . $description));
        }
    }
    
    private function insertMaps($node)
    {
        $path = "maps";
        $dir_handle = @opendir($path) or die("Unable to open $path");

        while ($file = readdir($dir_handle))
        {
            if ($file != "." && $file != ".." && stristr($file, ".bsp.bz2"))
            {
                $liNode = $node->appendChild(new DOMElement("li"));
                $liNode->appendChild(new DOMText($file));
            }
        }

        closedir($dir_handle);
    }
    
    private function createDocument()
    {
        $imp = new DOMImplementation();
        $doctype = $imp->createDocumentType("HTML", "-//W3C//DTD HTML 4.01//EN", "http://www.w3.org/TR/html4/strict.dtd");
        $dom = $imp->createDocument("", "html", $doctype);
        return $dom;
    }
    
    private function createCommandDom()
    {
        $dom = $this->createDocument();
        $html = $dom->documentElement;
        $head = $html->appendChild(new DOMElement("head"));
        $title = $head->appendChild(new DOMElement("title"));
        $title->appendChild(new DOMText("Ballerbude BOT Kommandos"));
        $body = $html->appendChild(new DOMElement("body"));
        $h1 = $body->appendChild(new DOMElement("h1"));
        $h1->appendChild(new DOMText("Alle derzeitigen BOT Kommandos:"));
        $h2 = $body->appendChild(new DOMElement("h2"));
        $h2->appendChild(new DOMText("Aufruf mit !bot \"command\""));
        $ul = $body->appendChild(new DOMElement("ul"));

        $this->insertCommands($ul);

        $this->document = $dom;
    }
    
    private function createMapsDom()
    {
        $dom = $this->createDocument();
        $html = $dom->documentElement;
        $head = $html->appendChild(new DOMElement("head"));
        $title = $head->appendChild(new DOMElement("title"));
        $title->appendChild(new DOMText("Ballerbude BOT Mapliste"));
        $body = $html->appendChild(new DOMElement("body"));
        $h1 = $body->appendChild(new DOMElement("h1"));
        $h1->appendChild(new DOMText("Alle derzeitigen Maps:"));
        
        $listElement = $body->appendChild(new DOMElement("ul"));
        $this->insertMaps($listElement);
        
        $this->document = $dom;
    }
    
    public function getDocument()
    {
        if ($this->document == null)
        {
            if ($this->commands !== null)
            {
                $this->createCommandDom();
            }
            else
            {
                $this->createMapsDom();
            }
        }

        return $this->document;
    }
}

if (isset($_GET['bot']))
{
    if ($_GET['bot'] == "info")
    {
        header("Content-type: text/html; charset=iso-8859-1");

        $commandWriter = new CommandHTMLWriter(
        array
        (
            "nextmap <mapname>" => "setzt die naechste map nach TIMELIMIT",
            "changemap <mapname>" => "setzt die naechste map unmittelbar nach dieser Runde",
            "ff" => "triggert mp_friendlyfire",
            "refresh" => "laedt alle Plugins neu",
            "hardcore" => "triggert sv_hardcore",
            "infrate <rate als Ganzzahl>" => "setzt die infection rate",
            "infrate" => "gibt die derzeitige infection rate aus",
            "slay <player>" => "toetet den angegebenen Spieler ueber dessen Nick. Der Nick muss eindeutig sein und kann in der Console mit \"status\" ausgelesen werden",
            "timelimit" => "gibt mp_timelimit aus",
            "timelimit <limit als Ganzzahl>" => "setzt mp_timelimit",
            "cheats" => "triggert sv_cheats"
        ));
        $document = $commandWriter->getDocument();
        $document->formatOutput = true;
        echo $document->saveHTML();
    }
    else if ($_GET['bot'] == "list")
    {
        header("Content-type: text/html; charset=iso-8859-1");

        $commandWriter = new CommandHTMLWriter();
        $document = $commandWriter->getDocument();
        $document->formatOutput = true;
        echo $document->saveHTML();
    }
    else
    {
        die("Unknown command");
    }
}
else
{
    # Gibt alle Maps aus dem maps/ Verzeichnis mit .bsp.bz2 im Namen als Liste aus
    $path = "maps";
    $dir_handle = @opendir($path) or die("Unable to open $path");

    while ($file = readdir($dir_handle))
    {
        if ($file != "." && $file != ".." && stristr($file, ".bsp.bz2"))
        {
            echo $file."\n";
        }
    }

    closedir($dir_handle);
}
?>
