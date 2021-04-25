require 'theseus'
require 'pry'

class MazeCat
  attr_accessor :maze
  attr_accessor :tile_images
  attr_accessor :tile_lookup
  attr_accessor :maze_image
  attr_accessor :maze_step

  def initialize
    self.tile_images = {}
    self.tile_lookup = {}
    self.maze_step = 0

    load_tiles
    build_tile_lookup

    # generate an orthogonal maze and turn it into loooong cats
    # use .new to generated step by step instead of generate
    self.maze = Theseus::OrthogonalMaze.generate(width: 20, height: 10, weave: 100, braid: 25)

    # Render full maze
    #File.open("maze.png", "w") { |f| f.write(maze.to(:png)) }
    #puts maze
    draw_cats maze

    # Render maze steps
    #while maze.step
    #  self.maze_step = maze_step + 1
    # 
    #  draw_cats maze
    #end

  end


  # IMAGE LOAD    ###############################################################

  def load_tiles
    print "Loading tiles..."

    tile_image_names = Dir.glob("tiles/*.png")

    tile_image_names.each do |name|
      name_without_extension_or_path = File.basename(name, ".*")
      tile_images[name_without_extension_or_path] = ChunkyPNG::Image.from_file name
    end

    print "done!\n"

  end

  def tile_for_cell cell_openings
    # return image or default
    image_name = tile_lookup[cell_openings]
    if !image_name
      puts "missing #{cell_openings}"
    end
    tile_images[image_name] || tile_images["missing"]
  end

  def build_tile_lookup
    ### Map tiles to walls ###

    # Empty
    tile_lookup["--------"] = "nocat"

    # One exit
    tile_lookup["N-------"] = "longcatbeans-n" 
    tile_lookup["-S------"] = "longcat-s" 
    tile_lookup["--W-----"] = "longcat-w" 
    tile_lookup["---E----"] = "longcatbeans-e" 

    # Two exit
    tile_lookup["NS------"] = "longcatislong-ns" 
    tile_lookup["--WE----"] = "longcatislong-we"

    tile_lookup["N-W-----"] = "longcatislong-nw" 
    tile_lookup["N--E----"] = "longcatislong-ne" 
    tile_lookup["-SW-----"] = "longcatislong-sw" 
    tile_lookup["-S-E----"] = "longcatislong-se" 

    # Two over Two
    tile_lookup["NS----WE"] = "longcatoverlap-ns-we" 
    tile_lookup["--WENS--"] = "longcatoverlap-we-ns" 

    # Three exit
    tile_lookup["NSW-----"] = "longcatopus-nsw" 
    tile_lookup["NS-E----"] = "longcatopus-nse" 
    tile_lookup["N-WE----"] = "longcatopus-nwe" 
    tile_lookup["-SWE----"] = "longcatopus-swe" 

    # Four exit
    tile_lookup["NSWE----"] = "longcatopus-nswe" 

  end


  # MAZE RENDER   ###############################################################

  def draw_cats maze
    image_width  = maze.width  * tile_images.first[1].width # returns [key,val] from hash
    image_height = maze.height * tile_images.first[1].height

    puts "#{image_width}x#{image_height} long space"
    self.maze_image = ChunkyPNG::Image.new image_width, image_height, ChunkyPNG::Color::TRANSPARENT


    maze.height.times do |y|
      maze.width.times do |x|
        draw_cell(x, y, maze[x, y])
      end
    end

    filename = "mazecat-%03d.png" % maze_step
    maze_image.save filename
    puts "Saving #{filename}"
  end


  def draw_cell x, y, cell 

    sides = []
    under = []

    north = cell & Theseus::Maze::N == Theseus::Maze::N
    south = cell & Theseus::Maze::S == Theseus::Maze::S
    west  = cell & Theseus::Maze::W == Theseus::Maze::W
    east  = cell & Theseus::Maze::E == Theseus::Maze::E
    north_under = (cell >> Theseus::Maze::UNDER_SHIFT) & Theseus::Maze::N == Theseus::Maze::N
    south_under = (cell >> Theseus::Maze::UNDER_SHIFT) & Theseus::Maze::S == Theseus::Maze::S
    west_under  = (cell >> Theseus::Maze::UNDER_SHIFT) & Theseus::Maze::W == Theseus::Maze::W
    east_under  = (cell >> Theseus::Maze::UNDER_SHIFT) & Theseus::Maze::E == Theseus::Maze::E

    sides.push north ? "N" : "-"
    sides.push south ? "S" : "-"
    sides.push west  ? "W" : "-"
    sides.push east  ? "E" : "-"
    under.push north_under ? "N" : "-"
    under.push south_under ? "S" : "-"
    under.push west_under  ? "W" : "-"
    under.push east_under  ? "E" : "-"

    cell_image = tile_for_cell sides.join + under.join

    x_pos =  tile_images.first[1].width * x
    y_pos =  tile_images.first[1].height * y
    maze_image.compose! cell_image, x_pos, y_pos
  end

end # MazeCat

MazeCat.new
