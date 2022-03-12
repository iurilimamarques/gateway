package com.chatappgateway.gateway.filter;

import com.chatappgateway.gateway.dto.JwtValidation;
import com.netflix.zuul.ZuulFilter;
import com.netflix.zuul.context.RequestContext;
import com.netflix.zuul.exception.ZuulException;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestTemplate;

import javax.servlet.http.HttpServletRequest;

@Component
public class AuthorizationFilter extends ZuulFilter {

    @Override
    public String filterType() {
        return "pre";
    }

    @Override
    public int filterOrder() {
        return 0;
    }

    @Override
    public boolean shouldFilter() {
        return true;
    }

    @Override
    public Object run() throws ZuulException {
        RequestContext ctx = RequestContext.getCurrentContext();
        HttpServletRequest request = ctx.getRequest();

        if (request.getRequestURL().toString().contains("/chat-app/api/auth/signin") ||
                request.getRequestURL().toString().contains("/chat-app/api/auth/signup") ||
                request.getRequestURL().toString().contains("/chat-app/api/auth/validate")) {
            return null;
        }

        try {
            String authorization = request.getHeader("Authorization");
            if (authorization == null) {
                throw new ZuulException("No authorization token provided", 500, "");
            } else {
                String jwtToken = authorization.replace("Bearer ", "");
                String URL_JWT_VALIDATION = "https://auth-chatapp.herokuapp.com/auth/jwt-validation/validate-token/" + jwtToken;

                RestTemplate restTemplate = new RestTemplate();
                JwtValidation response = restTemplate.getForObject(URL_JWT_VALIDATION, JwtValidation.class);
                if (response.getStatus().equals("JWT_NOT_VALID")) {
                    throw new ZuulException(response.getMessage(), 500, "JWT_NOT_VALID");
                }
            }
        } catch (ZuulException e) {
            throw e;
        }

        return null;
    }
}
