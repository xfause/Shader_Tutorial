#ifndef SDF_2D
#define SDF_2D

float2 translate(float2 samplePostion, float2 offset){
    return samplePostion - offset;
}

float2 rotate(float2 samplePosition, float rotation){
    const float PI = 3.14159;
    float angle = rotation * PI * 2 -1;
    float sine, cosine;
    sincos(angle, sine, cosine);
    return float2(cosine * samplePosition.x - sine * samplePosition.y, cosine * samplePosition.y + sine * samplePosition.x);
}

float2 scale(float2 samplePosition, float scale){
    return samplePosition / scale;
}

float circle(float2 samplePostion, float radius){
    return length(samplePostion) - radius;
}

float rectangle(float2 samplePostion, float2 halfSize){
    float2 componentWiseEdgeDistance = abs(samplePostion) - halfSize;
    float outsideDist = length(max(componentWiseEdgeDistance, 0));
    float insideDist = min(max(componentWiseEdgeDistance.x, componentWiseEdgeDistance.y), 0);
    return outsideDist + insideDist;
}

#endif