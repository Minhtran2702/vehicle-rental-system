package com.vehiclerental.auth;

import com.vehiclerental.common.AuthPrincipal;
import com.vehiclerental.entity.User;
import com.vehiclerental.repository.UserRepository;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.filter.OncePerRequestFilter;

/** Đọc header "Authorization: Bearer <token>", nếu hợp lệ và tài khoản còn hoạt động thì đăng nhập cho request này. */
public class JwtAuthFilter extends OncePerRequestFilter {

    private final JwtService jwtService;
    private final UserRepository userRepository;

    public JwtAuthFilter(JwtService jwtService, UserRepository userRepository) {
        this.jwtService = jwtService;
        this.userRepository = userRepository;
    }

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain chain)
            throws ServletException, IOException {
        String header = request.getHeader("Authorization");
        if (header != null && header.startsWith("Bearer ")) {
            try {
                AuthPrincipal p = jwtService.parse(header.substring(7));
                User u = userRepository.findById(p.id()).orElse(null);
                if (u != null && "ACTIVE".equals(u.getStatus())) {
                    AuthPrincipal current = new AuthPrincipal(u.getId(), u.getEmail(), u.getRole().getName());
                    UsernamePasswordAuthenticationToken auth = new UsernamePasswordAuthenticationToken(
                            current, null, List.of(new SimpleGrantedAuthority("ROLE_" + u.getRole().getName())));
                    SecurityContextHolder.getContext().setAuthentication(auth);
                }
            } catch (RuntimeException ex) {
                // token sai hoặc hết hạn: coi như chưa đăng nhập, các đường dẫn cần đăng nhập sẽ trả 401
            }
        }
        chain.doFilter(request, response);
    }
}
