mountains <- function(iter, roughness=0.5, m=0, sdev=1) {
  # Function to create mountainous terrain via the 
  # diamond-square algorithm.
  #
  # Arguments:
  # iter: integer. Number of iterations (determines
  #   size of finished terrain matrix).
  # roughness: float, between 0 and 1.  Factor by
  #   which the random deviations are reduced
  #   between iterations.
  # m: optional initial matrix, must be square
  #   with a dimension equal to a power of
  #   two (i.e., 2 ^ number of iterations) plus 1.
  # sdev: optional float. Inital standard deviation
  #   for the random deviations.
  # Value:
  # A square matrix of elevation values.
  
  size <- 2^iter + 1
  # If the user does not supply a matrix,
  # initalize one with zeros.
  if (! m) {
    m <- matrix(0, size, size)
  }
  # Loop through side lengths, starting with the size of the
  # entire matrix, and moving down by factors of 2.
  for (side.length in 2^(iter:1)) {
    half.side <- side.length / 2
    # Square step
    for (col in seq(1, size - 1, by=side.length)) {
      for (row in seq(1, size - 1, by=side.length)) {
        avg <- mean(c(
          m[row, col],        # upper left
          m[row + side.length, col],  # lower left
          m[row, col + side.length],  # upper right
          m[row + side.length, col + side.length] #lower right
        ))
        avg <- avg + rnorm(1, 0, sdev)
        m[row + half.side, col + half.side] <- avg
      }
    }
    
    # Diamond step
    for (row in seq(1, size, by=half.side)) {
      for (col in seq((col+half.side) %% side.length, size, side.length)) {
        # m[row, col] is the center of the diamond
        avg <- mean(c(
          m[(row - half.side + size) %% size, col],# above
          m[(row + half.side) %% size, col], # below
          m[row, (col + half.side) %% size], # right
          m[row, (col - half.side) %% size]  # left
        ))
        m[row, col] <- avg + rnorm(1, 0, sdev)
        # Handle the edges by wrapping around to the
        # other side of the array
        if (row == 0) { m[size - 1, col] = avg }
        if (col == 0) { m[row, size - 1] = avg }
      }
    }
    # Reduce the standard deviation of the random deviation
    # by the roughness factor.
    sdev <- sdev * roughness
  }
  return(m)
}