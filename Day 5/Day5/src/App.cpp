#include <glad/glad.h>
#include <GLFW/glfw3.h>
#include <iostream>
#include <vector>
#include <fstream>
#include <string>
#include <fstream>
#include <regex>

const int textureSizeWidth = 2048;
const int textureSizeHeight = 2048;


struct coordinate {
    int x, y;
};

struct inputDataLine {
    coordinate from, to;
};

GLfloat* convertToLines(std::vector<inputDataLine> coordinates) {
    int size = coordinates.size();
    GLfloat* convertedCoordinates = new GLfloat[size * 2 * 3];

    const double pixelSize = 1 / (double)textureSizeWidth;
    const double firstOffset = 0; // 1 / (2 * (double)textureSizeWidth);

    for (int i = 0; i < size; i++) {
        convertedCoordinates[6 * i + 0] = 2 * ((coordinates.at(i).from.x + 1 + 100) * pixelSize + firstOffset) - 1;
        convertedCoordinates[6 * i + 1] = 2 * ((coordinates.at(i).from.y + 1 + 100) * pixelSize + firstOffset) - 1;
        convertedCoordinates[6 * i + 2] = 0;

        convertedCoordinates[6 * i + 3] = 2 * ((coordinates.at(i).to.x + 1 + 100) * pixelSize + firstOffset) - 1;
        convertedCoordinates[6 * i + 4] = 2 * ((coordinates.at(i).to.y + 1 + 100) * pixelSize + firstOffset) - 1;
        convertedCoordinates[6 * i + 5] = 0;
    }

    return convertedCoordinates;
}


GLfloat* convertToPositions(std::vector<inputDataLine> coordinates) {
    int size = coordinates.size();
    GLfloat* convertedCoordinates = new GLfloat[size * 3];

    const double pixelSize = 1 / (double)textureSizeWidth;
    const double firstOffset = 0; // 1 / (2 * (double)textureSizeWidth);

    for (int i = 0; i < size; i++) {
        convertedCoordinates[3 * i + 0] = 2 * ((std::min(coordinates.at(i).from.x, coordinates.at(i).to.x) + 100) * pixelSize + firstOffset) - 1;
        convertedCoordinates[3 * i + 1] = 2 * ((std::min(coordinates.at(i).from.y, coordinates.at(i).to.y) + 100) * pixelSize + firstOffset) - 1;
        convertedCoordinates[3 * i + 2] = 0;
    }

    return convertedCoordinates;
}

std::vector<inputDataLine> readInputFile(const char* filePath) {
    std::vector<inputDataLine> coordinates;

    std::ifstream infile(filePath, std::ios::in);
    if (!infile.is_open()) {
        std::cerr << "Could not read file " << filePath << ". File does not exist." << std::endl;
        return coordinates;

    }
    
    const std::regex r("(.*),(.*) -> (.*),(.*)");
    std::smatch sm;

    std::string line;
    while (std::getline(infile, line))
    {
        if (std::regex_search(line, sm, r)) {
            inputDataLine idl;
            idl.from.x = std::stoi(sm[1]);
            idl.from.y = std::stoi(sm[2]);
            idl.to.x = std::stoi(sm[3]);
            idl.to.y = std::stoi(sm[4]);

            // part 1
            /*if (idl.from.x != idl.to.x && idl.from.y != idl.to.y) {
                continue;
            }*/

            // part 2
            if (std::abs(idl.from.x - idl.to.x) == std::abs(idl.from.y != idl.to.y)) {
                continue;
            }

            coordinates.push_back(idl);
        }
    }

    return coordinates;
}

std::string readFile(const char* filePath) {
    std::string content;
    std::ifstream fileStream(filePath, std::ios::in);

    if (!fileStream.is_open()) {
        std::cerr << "Could not read file " << filePath << ". File does not exist." << std::endl;
        return "";
    }

    std::string line = "";
    while (!fileStream.eof()) {
        std::getline(fileStream, line);
        content.append(line + "\n");
    }


    fileStream.close();
    return content;
}

GLuint LoadShaders(const char* vertex_file_path, const char* fragment_file_path) {
    std::string vertShaderStr = readFile(vertex_file_path);
    std::string fragShaderStr = readFile(fragment_file_path);

    const char* vertexSourcePointer = vertShaderStr.c_str();
    const char* fragmentSourcePointer = fragShaderStr.c_str();

	// Create the shaders
	GLuint VertexShaderID = glCreateShader(GL_VERTEX_SHADER);
	GLuint FragmentShaderID = glCreateShader(GL_FRAGMENT_SHADER);

	GLint Result = GL_FALSE;
	int InfoLogLength;

	// Compile Vertex Shader
	printf("Compiling shader : %s\n", vertex_file_path);
	glShaderSource(VertexShaderID, 1, &vertexSourcePointer, NULL);
	glCompileShader(VertexShaderID);

	// Check Vertex Shader
	glGetShaderiv(VertexShaderID, GL_COMPILE_STATUS, &Result);
	glGetShaderiv(VertexShaderID, GL_INFO_LOG_LENGTH, &InfoLogLength);
	if (InfoLogLength > 0) {
		std::vector<char> VertexShaderErrorMessage(InfoLogLength + 1);
		glGetShaderInfoLog(VertexShaderID, InfoLogLength, NULL, &VertexShaderErrorMessage[0]);
		printf("%s\n", &VertexShaderErrorMessage[0]);
	}

	// Compile Fragment Shader
	printf("Compiling shader : %s\n", fragment_file_path);
	glShaderSource(FragmentShaderID, 1, &fragmentSourcePointer, NULL);
	glCompileShader(FragmentShaderID);

	// Check Fragment Shader
	glGetShaderiv(FragmentShaderID, GL_COMPILE_STATUS, &Result);
	glGetShaderiv(FragmentShaderID, GL_INFO_LOG_LENGTH, &InfoLogLength);
	if (InfoLogLength > 0) {
		std::vector<char> FragmentShaderErrorMessage(InfoLogLength + 1);
		glGetShaderInfoLog(FragmentShaderID, InfoLogLength, NULL, &FragmentShaderErrorMessage[0]);
		printf("%s\n", &FragmentShaderErrorMessage[0]);
	}

	// Link the program
	printf("Linking program\n");
	GLuint ProgramID = glCreateProgram();
	glAttachShader(ProgramID, VertexShaderID);
	glAttachShader(ProgramID, FragmentShaderID);
	glLinkProgram(ProgramID);

	// Check the program
	glGetProgramiv(ProgramID, GL_LINK_STATUS, &Result);
	glGetProgramiv(ProgramID, GL_INFO_LOG_LENGTH, &InfoLogLength);
	if (InfoLogLength > 0) {
		std::vector<char> ProgramErrorMessage(InfoLogLength + 1);
		glGetProgramInfoLog(ProgramID, InfoLogLength, NULL, &ProgramErrorMessage[0]);
		printf("%s\n", &ProgramErrorMessage[0]);
	}

	glDetachShader(ProgramID, VertexShaderID);
	glDetachShader(ProgramID, FragmentShaderID);

	glDeleteShader(VertexShaderID);
	glDeleteShader(FragmentShaderID);

	return ProgramID;
}


int main(void)
{
    std::vector<inputDataLine> coordinates = readInputFile("asset\\input.txt");
    const int inputDataLineCount = coordinates.size();
    const int vertexCount = inputDataLineCount * 2;
    GLfloat* verticesLines = convertToLines(coordinates);
    GLfloat* verticesPositions = convertToPositions(coordinates);
    
    /* Initialize the library */
    if (!glfwInit())
        return -1;

    /* Create a windowed mode window and its OpenGL context */
    GLFWwindow* window = glfwCreateWindow(textureSizeWidth, textureSizeHeight, "Hello World", NULL, NULL);
    if (window == NULL)
    {
        std::cout << "Failed to create GLFW window" << std::endl;
        glfwTerminate();
        return -1;
    }
    
    /* Make the window's context current */
    glfwMakeContextCurrent(window);


    if (!gladLoadGLLoader((GLADloadproc)glfwGetProcAddress))
    {
        std::cout << "Failed to initialize GLAD" << std::endl;
        return -1;
    }

    /// -----------------------------------------
    
    int program = LoadShaders("shader\\vertex.glsl", "shader\\fragment.glsl");

    // This will identify our vertex buffer
    GLuint vertexbufferLines;
    // Generate 1 buffer, put the resulting identifier in vertexbuffer
    glGenBuffers(1, &vertexbufferLines);
    // The following commands will talk about our 'vertexbuffer' buffer
    glBindBuffer(GL_ARRAY_BUFFER, vertexbufferLines);
    // Give our vertices to OpenGL.
    glBufferData(GL_ARRAY_BUFFER, vertexCount * 3 * sizeof(GL_FLOAT), verticesLines, GL_STATIC_DRAW);

    // This will identify our vertex buffer
    GLuint vertexbufferPositions;
    // Generate 1 buffer, put the resulting identifier in vertexbuffer
    glGenBuffers(1, &vertexbufferPositions);
    // The following commands will talk about our 'vertexbuffer' buffer
    glBindBuffer(GL_ARRAY_BUFFER, vertexbufferPositions);
    // Give our vertices to OpenGL.
    glBufferData(GL_ARRAY_BUFFER, inputDataLineCount * 3 * sizeof(GL_FLOAT), verticesPositions, GL_STATIC_DRAW);

    //
    /// -----------------------------------------
    
    int count = 102;

    /* Loop until the user closes the window */
    while (!glfwWindowShouldClose(window))
    {
        /* Render here */
        glClear(GL_COLOR_BUFFER_BIT);

        glUseProgram(program);

        glEnable(GL_BLEND);
        glBlendFunc(GL_ONE, GL_ONE);

        // 1st attribute buffer : vertices
        glEnableVertexAttribArray(0);
        glBindBuffer(GL_ARRAY_BUFFER, vertexbufferLines);
        glVertexAttribPointer(
            0,                  // attribute 0. No particular reason for 0, but must match the layout in the shader.
            3,                  // size
            GL_FLOAT,           // type
            GL_FALSE,           // normalized?
            0,                  // stride
            (void*)0            // array buffer offset
        );
        // Draw the triangle !
        glDrawArrays(GL_LINES, 0, count * 2); // Starting from vertex 0; 3 vertices total -> 1 triangle
        glDisableVertexAttribArray(0);

        glEnableVertexAttribArray(0);
        glBindBuffer(GL_ARRAY_BUFFER, vertexbufferPositions);
        glVertexAttribPointer(
            0,                  // attribute 0. No particular reason for 0, but must match the layout in the shader.
            3,                  // size
            GL_FLOAT,           // type
            GL_FALSE,           // normalized?
            0,                  // stride
            (void*)0            // array buffer offset
        );
        // Draw the triangle !
        glDrawArrays(GL_POINTS, 0, count); // Starting from vertex 0; 3 vertices total -> 1 triangle
        glDisableVertexAttribArray(0);


        ///* Swap front and back buffers */
        glfwSwapBuffers(window);

        int width, height;
        int numberCrossingPixels = 0;
        glfwGetFramebufferSize(window, &width, &height);
        GLsizei nrChannels = 3;
        GLsizei stride = nrChannels * width;
        stride += (stride % 4) ? (4 - stride % 4) : 0;
        GLsizei bufferSize = stride * height;
        std::vector<GLubyte> buffer(bufferSize);
        glPixelStorei(GL_PACK_ALIGNMENT, 4);
        glReadBuffer(GL_FRONT);
        glReadPixels(0, 0, width, height, GL_RGB, GL_UNSIGNED_BYTE, buffer.data());

        int fetchedBufferSize = buffer.size();
        for (int i = 0; i < fetchedBufferSize; i += 3) {
            GLubyte r = buffer.at(i + 0);
            GLubyte g = buffer.at(i + 1);
            GLubyte b = buffer.at(i + 2);

            if (r > 200) {
                numberCrossingPixels += 1;
            }
        }

        std::cout << count << " has pixels " << numberCrossingPixels << std::endl;
        
        /* Poll for and process events */
        glfwPollEvents();

        int state = glfwGetKey(window, GLFW_KEY_E);
        if (state == GLFW_PRESS)
        {
            count += 1;
        }
        state = glfwGetKey(window, GLFW_KEY_DOWN);
        if (state == GLFW_PRESS)
        {
            count -= 1;
        }
    }

    delete verticesLines;
    //delete verticesPositions;

    glfwTerminate();
    return 0;
}
