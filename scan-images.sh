#!/bin/bash

echo " Scanning Nginx base images for vulnerabilities..."
echo "=================================================="

# Images to scan
images=("nginx:alpine" "nginx:stable-alpine" "bitnami/nginx:latest")

# Create results directory
mkdir -p results

# Scan each image
for image in "${images[@]}"; do
    echo ""
    echo " Scanning: $image"
    echo "------------------------"
    
    # Pull image if not exists
    docker pull "$image" 2>/dev/null
    
    # Scan with Trivy
    trivy image --format table --quiet "$image" > "results/scan-${image//[:\/]/-}.txt" 2>/dev/null
    
    # Extract summary
    echo " Scan completed for $image"
done

echo ""
echo " Generating summary table..."
echo "============================="

# Create markdown table
echo "| Image | Total | Critical | High | Medium | Low |"
echo "|-------|-------|----------|------|--------|-----|"

for image in "${images[@]}"; do
    filename="results/scan-${image//[:\/]/-}.txt"
    if [ -f "$filename" ]; then
        total=$(grep "Total:" "$filename" | awk '{print $2}' || echo "0")
        critical=$(grep "CRITICAL:" "$filename" | awk '{print $2}' || echo "0")
        high=$(grep "HIGH:" "$filename" | awk '{print $2}' || echo "0")
        medium=$(grep "MEDIUM:" "$filename" | awk '{print $2}' || echo "0")
        low=$(grep "LOW:" "$filename" | awk '{print $2}' || echo "0")
        
        echo "| $image | $total | $critical | $high | $medium | $low |"
    fi
done

echo ""
echo " Detailed results saved in 'results/' directory"
echo " To run full GitHub Actions comparison, push your changes:"
