CXX = g++
CXXFLAGS = -std=c++11 -Wall

TARGET = golomb_test

SOURCES = TestGolomb.cpp BitStream.cpp Golomb.cpp

OBJECTS = $(SOURCES:.cpp=.o)

$(TARGET): $(OBJECTS)
	$(CXX) $(CXXFLAGS) -o $(TARGET) $(OBJECTS)

# Compile .cpp files to .o files
%.o: %.cpp
	$(CXX) $(CXXFLAGS) -c $< -o $@

# Clean up build files
clean:
	rm -f $(TARGET) $(OBJECTS)

# Run the program with default values
run: $(TARGET)
	./$(TARGET)
